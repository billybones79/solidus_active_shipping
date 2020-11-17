# handle shipping errors gracefully during order update
module Spree::Admin::OrdersControllerDecorator
  def self.prepended(base)


  end
  def labels
    require 'combine_pdf'
    load_order
    label_file = Tempfile.new("label.pdf", encoding: 'ascii-8bit')
    label_pdf = @order.shipments.first.used_shipping_rate.shipping_method.calculator.carrier.get_label(@order.shipments.first.label_url)
    label_file.write(label_pdf)
    return_file = Tempfile.new("return.pdf", encoding: 'ascii-8bit')
    return_pdf = @order.shipments.first.used_shipping_rate.shipping_method.calculator.carrier.get_label(@order.shipments.first.return_label_url)
    return_file.write(return_pdf)


    pdf = ::CombinePDF.new
    pdf << ::CombinePDF.load(label_file.path) # one way to combine, very fast.
    pdf << ::CombinePDF.load(return_file.path)
    pdf.save "combined.pdf"
    send_data pdf.to_pdf, filename: @order.number+".pdf", type: "application/pdf"
  end

  def shipment_label
    require 'combine_pdf'
    @shipment = Spree::Shipment.where(number: params[:id]).first
    retries=0
    begin
      label_file = Tempfile.new("label.pdf", encoding: 'ascii-8bit')
      label_pdf = @shipment.used_shipping_rate.shipping_method.calculator.carrier.get_label(@shipment.label_url)
      label_file.write(label_pdf)
    rescue  Exception =>e
      retries = retries+1
      retry unless retries>5
    end
    retries=0
    begin

      return_file = Tempfile.new("return.pdf", encoding: 'ascii-8bit')
      return_pdf = @shipment.used_shipping_rate.shipping_method.calculator.carrier.get_label(@shipment.return_label_url)
      return_file.write(return_pdf)
    rescue  Exception =>e
      retries = retries+1
      retry unless retries>5
    end


    pdf = ::CombinePDF.new
    pdf << ::CombinePDF.load(label_file.path) # one way to combine, very fast.
    pdf << ::CombinePDF.load(return_file.path)
    pdf.save "combined.pdf"
    send_data pdf.to_pdf, filename: @shipment.number+".pdf", type: "application/pdf"
  end

  private
    def handle_shipping_error(e)
      flash[:error] = e.message
      redirect_back_or_default(root_path)
    end
  Spree::Admin::OrdersController.prepend self
end