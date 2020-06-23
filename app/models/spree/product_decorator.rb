# Add product packages relation
module Spree::ProductDecorator
  def self.prepended(base)
    base.class_eval do
      has_many :product_packages, dependent: :destroy
      accepts_nested_attributes_for :product_packages, allow_destroy: true, reject_if: ->(pp) { pp[:weight].blank? || Integer(pp[:weight]) < 1 }
    end
  end
  def has_product_packages?
    product_packages.any?
  end

  Spree::Product.prepend self
end
