Spree::Core::Engine.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    resources :pws_shipping_manifests do
      member do
        put :transmit
        put :confirm
      end
    end
  end

  namespace :admin do


    resources :pws_shipping_manifests do
      member do
        put :transmit
      end
    end
    resources :orders do
      member do
        get :labels, as: "labels"
      end
    end

    get "/shipments/:id/labels" , to:"orders#shipment_label", as: "shipment_labels"

    resource :active_shipping_settings, :only => ['show', 'update', 'edit']

    resources :products, :only => [] do
      resources :product_packages
    end
  end
end
