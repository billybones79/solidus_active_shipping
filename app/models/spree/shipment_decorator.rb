module Spree::ShipmentDecorator


  def self.prepended(base)
    base.class_eval do
      state_machine.before_transition :to => :shipped, :do => :prepare_canadapost_shipment
      self.whitelisted_ransackable_associations = ['shipping_rates']
    end
  end



  def dimentions=(dimentions)
    self.width = dimentions["width"]

    self.length = dimentions["length"]
    self.height = dimentions["height"]
    self.weight = dimentions["weight"]

  end

  def dimentions
    {width: width, height: height, length: length, weight: weight}

  end
  def weight
    unless self[:weight]

      line_items.map(&:variant).flatten.sum{|v| v.weight}
    end
    self[:weight]
  end

  def used_method
    used_shipping_rate.try(:shipping_method)
  end





  def refresh_rates

    return shipping_rates if shipped?
    return [] unless can_get_rates?

    # StockEstimator.new assigment below will replace the current shipping_method
    original_shipping_method_id = shipping_method.try!(:id)
    used_shipping_method_id = used_method.try!(:id)

    new_rates = Spree::Config.stock.estimator_class.new.shipping_rates(to_package, false)

    # If one of the new rates matches the previously selected shipping
    # method, select that instead of the default provided by the estimator.
    # Otherwise, keep the default.
    selected_rate = new_rates.detect{ |rate| rate.shipping_method_id == original_shipping_method_id }
    used_rate = new_rates.detect{ |rate| rate.shipping_method_id == used_shipping_method_id }

    if selected_rate
      new_rates.each do |rate|
        rate.selected = (rate == selected_rate)
        rate.used = (rate == used_rate)
      end
    end


    self.shipping_rates = new_rates
    save!

    #side_effect.exe
    unless used_shipping_rate
      set_default_backend_shipping
    end


    shipping_rates

  end

  def used_shipping_rate
    shipping_rates.where(used: true).first
  end

  def used_shipping_rate_id
    used_shipping_rate.try(:id)
  end

  def used_shipping_rate_id=(id)
    shipping_rates.update_all(used: false)
    shipping_rates.update(id, used: true)

    self.save!
    self.order.create_tax_charge!

  end


  def canada_post_tracking_url(tracking_number, label_url, return_label_url)
    self.update_columns(
        tracking: tracking_number,
        label_url: label_url,
        return_label_url: return_label_url
    )
  end

  def retrieve_shipping_info

    return "" if tracking.nil?

    canada_post_options = {
        :api_key => Spree::ActiveShipping::Config[:canada_post_pws_api_key],
        :secret => Spree::ActiveShipping::Config[:canada_post_pws_secret],
        :endpoint => Spree::ActiveShipping::Config[:test_mode] ?
                         'https://ct.soa-gw.canadapost.ca/' : nil,
        :customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number],
        :language => I18n.locale.to_sym
    }

    cpws = ActiveShipping::CanadaPostPWS.new(canada_post_options)

    #tracking_info = cpws.find_tracking_info('4006406840810168')
    tracking_info = cpws.find_tracking_info(tracking)

    puts "#{tracking_info.inspect}"

    if tracking_info.delivered? && tracking_info.actual_delivery_time
      self.update_columns(
          delivered_at: tracking_info.actual_delivery_time,
          )

    end
    #response = []

    #tracking_info.shipment_events.each do |event|
    #  response << "#{event.name} at #{event.location} on #{event.time}. #{event.message}"
    #end

    return tracking_info

  rescue ::ActiveShipping::Error => e
    return e.message
  end

  def retrieve_label_url

    canada_post_options = {
        :api_key => Spree::ActiveShipping::Config[:canada_post_pws_api_key],
        :secret => Spree::ActiveShipping::Config[:canada_post_pws_secret],
        :endpoint => Spree::ActiveShipping::Config[:test_mode] ?
                         'https://ct.soa-gw.canadapost.ca/' : nil,
        :customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number],
        :contract_id => Spree::ActiveShipping::Config[:canada_post_pws_contract_id],
        :language => I18n.locale.to_sym
    }

    cpws = ActiveShipping::CanadaPostPWS.new(canada_post_options)

    cpws.retrieve_shipping_label(shipment)

  end

  def prepare_canadapost_shipment

    if used_shipping_rate.nil?
      raise "Information incomplète"
    else

      if !used_shipping_rate.shipping_method_code || used_shipping_rate.shipping_method_code == "EM" || used_shipping_rate.shipping_method_code == "RM"
        return true
      end

      begin

        if  weight <= 0.0
          raise "Information incomplète"
        else
          from = ActiveShipping::Location.new(  :country => stock_location.country.iso,
                                                :state => stock_location.state.abbr,
                                                :company => order.store.name,
                                                :city => stock_location.city,
                                                :zip => stock_location.zipcode,
                                                :address1 => stock_location.address1,
                                                :address2 => stock_location.address2,
                                                :phone => stock_location.phone)


          to = ActiveShipping::Location.new(
              :name => "#{address.firstname} #{address.lastname}",
              :country => address.country.iso,
              :state => address.state.abbr,
              :city => address.city,
              :zip => address.zipcode,
              :address1 => address.address1,
              :address2 => address.address2,
              :phone => address.phone)

          if width && width > 0.0 && length && length > 0.0 && height && height > 0.0
            package = ActiveShipping::Package.new(weight * 1000, [length, width, height], :units => :metric)  # not grams, not centimetres
          else
            package = ActiveShipping::Package.new(weight * 1000, [], :units => :metric)  # not grams, not centimetres
          end



          canada_post_options = {
              :api_key => Spree::ActiveShipping::Config[:canada_post_pws_userid],
              :secret => Spree::ActiveShipping::Config[:canada_post_pws_password],
              :endpoint => Spree::ActiveShipping::Config[:test_mode] ?
                               'https://ct.soa-gw.canadapost.ca/' : nil,
              :customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number],
              :contract_id => Spree::ActiveShipping::Config[:canada_post_pws_contract_number],
              :language => I18n.locale.to_sym
          }

          cpws = ActiveShipping::CanadaPostPWS.new(canada_post_options)

          opts = {:customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number], :contract_id => Spree::ActiveShipping::Config[:canada_post_pws_contract_number], :service => used_shipping_rate.shipping_method_code, :output_format => "4x6"}

          #cpws.get_groups(opts)

          shipment = cpws.create_contract_shipment(from, to, package,'', opts)

          canada_post_tracking_url(shipment.tracking_number, shipment.label_url, shipment.return_label_url)

        end
      rescue => e
        raise e
      end
    end

  end


  def credentialed_label_url
    return "" unless label_url
     label_url.insert(8, "#{Spree::ActiveShipping::Config[:canada_post_pws_userid]}:#{Spree::ActiveShipping::Config[:canada_post_pws_password]}@")

  end

  def credentialed_return_label_url
    return "" unless return_label_url
    return_label_url.insert(8, "#{Spree::ActiveShipping::Config[:canada_post_pws_userid]}:#{Spree::ActiveShipping::Config[:canada_post_pws_password]}@")

  end




  def require_store_location?
    shipping_method.in_store
  end

  Spree::Shipment.prepend self

end
