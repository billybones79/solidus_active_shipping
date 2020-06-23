require 'ostruct'

  class Spree::PwsShippingManifest < Spree::Base

    has_many :shipping_groups
    has_many :state_changes, as: :stateful
    has_many :log_entries, as: :source
    accepts_nested_attributes_for :shipping_groups

    state_machine initial: :pending, use_transactions: false do

      event :transmit do
        transition from: [:ready, :pending], to: :transmitted
      end

      event :confirm do
        transition from: [:transmitted], to: :confirmed
      end

      after_transition do |manifest, transition|
        manifest.state_changes.create!(
            previous_state: transition.from,
            next_state:     transition.to,
            name:           'manifest',
        )
      end
    end

    state_machine.before_transition :to => :transmitted, :do => :transmit_shipments
    state_machine.before_transition :to => :confirmed, :do => :get_manifest

    def set_manifest_url(manifest_url)
      self.update_columns(
          manifest_url: manifest_url
      )
    end

    def set_manifest_pdf_url(manifest_url)
      self.update_columns(
          manifest_url: manifest_url
      )
    end

    def self.canada_post_options
       {
          :api_key => Spree::ActiveShipping::Config[:canada_post_pws_userid],
          :secret => Spree::ActiveShipping::Config[:canada_post_pws_password],
          :endpoint => Spree::ActiveShipping::Config[:test_mode] ?
              'https://ct.soa-gw.canadapost.ca/' : nil,
          :customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number],
          :contract_id => Spree::ActiveShipping::Config[:canada_post_pws_contract_number],
          :language => I18n.locale.to_sym
      }
    end

    def transmit_shipments
      begin
      groups = shipping_groups.pluck(:name)



      cpws = ActiveShipping::CanadaPostPWS.new(Spree::PwsShippingManifest.canada_post_options)

      opts = {:customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number], :contract_id => Spree::ActiveShipping::Config[:canada_post_pws_contract_number]}

      stock_location = Spree::StockLocation.first

      from = ActiveShipping::Location.new(  :country => stock_location.country.iso,
                                            :state => stock_location.state.abbr,
                                            :company => 'Eugene Allard',
                                            :city => stock_location.city,
                                            :zip => stock_location.zipcode,
                                            :address1 => stock_location.address1,
                                            :address2 => stock_location.address2,
                                            :phone => stock_location.phone)

      groups = cpws.transmit_shipments(from, groups, opts)

      set_manifest_url(groups.manifest_url)

      log_entries.create!(:details => groups.to_yaml)

      rescue => e
        raise e
      end
    end

    def get_manifest
      begin



        cpws = ActiveShipping::CanadaPostPWS.new(Spree::PwsShippingManifest.canada_post_options)

        opts = {:customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number], :contract_id => Spree::ActiveShipping::Config[:canada_post_pws_contract_number]}

        response = log_entries.first.details

        transmit_shipment_response = YAML::load(response)

        manifest = cpws.get_manifest(transmit_shipment_response, opts)

        unless manifest.artifact
          raise "Veuillez réess"
        end
        set_manifest_pdf_url(manifest.artifact)

        log_entries.create!(:details => manifest.to_yaml)



      rescue => e
        raise e
      end
    end

    def self.get_groups

      begin



        cpws = ActiveShipping::CanadaPostPWS.new(canada_post_options)

        opts = {:customer_number => Spree::ActiveShipping::Config[:canada_post_pws_customer_number], :contract_id => Spree::ActiveShipping::Config[:canada_post_pws_contract_number]}

        groups = cpws.get_contract_shipment_groups(opts)

        return groups

      rescue => e
        raise e
      end
    end

  end
