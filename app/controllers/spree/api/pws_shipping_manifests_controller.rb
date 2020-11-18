module Spree
  module Api
    class PwsShippingManifestsController < Spree::Api::BaseController

      before_action :find_and_update_shipment, only: [:transmit]


      def transmit
        unless @shipping_manifest.transmitted?
          @shipping_manifest.transmit!
        end

        respond_with(@shipping_manifest, default_template: :show)
      end

      def confirm
        @shipping_manifest = Spree::PwsShippingManifest.find(params[:id])

        unless @shipping_manifest.confirmed?
          @shipping_manifest.confirm!
        end

        respond_with(@shipping_manifest, default_template: :show)
      end

      private


      def find_and_update_shipment
        @shipping_manifest = Spree::PwsShippingManifest.find(params[:id])
      end
    end
  end
end
