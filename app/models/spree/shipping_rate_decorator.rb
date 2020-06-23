module Spree::ShippingRateDecorator
  def self.prepended(base)
    delegate :rate, to: :shipment
  end
  Spree::ShippingRate.prepend self

end
