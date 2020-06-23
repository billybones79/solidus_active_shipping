# Add product packages relation
module Spree::LineItemDecorator
  def self.prepended(base)
    base.class_eval do
      has_many :product_packages, :through => :product
    end
  end
  Spree::LineItem.prepend self
end