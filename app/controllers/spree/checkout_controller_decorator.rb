# handle shipping errors gracefully during checkout
module Spree::CheckoutControllerDecorator
  extend ActiveSupport::Concern
  include ActiveSupport::Rescuable

  def self.prepended(base)
    base.class_eval do
      rescue_from Spree::ShippingError, :with => :handle_shipping_error
    end
  end

  private
    def handle_shipping_error(e)
      flash[:error] = e.message
      redirect_to checkout_state_path(:address)
    end
  Spree::CheckoutController.prepend self
end
