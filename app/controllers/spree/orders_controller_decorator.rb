# handle shipping errors gracefully during order update
module Spree::OrdersControllerDecorator
  def self.prepended(base)
    base.class_eval do
     rescue_from Spree::ShippingError, :with => :handle_shipping_error
    end
  end
  private
    def handle_shipping_error(e)
      flash[:error] = e.message
      redirect_back_or_default(root_path)
    end
  Spree::OrdersController.prepend self
end