Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :pws_shipping_manifests do
      member do
        put :transmit
      end
    end

    resource :active_shipping_settings, :only => ['show', 'update', 'edit']

    resources :products, :only => [] do
      resources :product_packages
    end
  end
end
