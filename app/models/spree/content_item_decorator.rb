module Spree
  module Stock::ContentItemDecorator
    def self.prepended(base)
      delegate :has_product_packages?, to: :variant, prefix: true
    end
      Spree::Stock::ContentItem.prepend self
  end
end
