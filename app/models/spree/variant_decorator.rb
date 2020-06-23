module Spree::VariantDecorator
  def self.prepended(base)
   delegate :has_product_packages?, to: :product
  end
  Spree::Variant.prepend self

end
