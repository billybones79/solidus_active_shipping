class AddDimentionsToShipments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_shipments, :label_url, :string
    add_column :spree_shipments, :return_label_url, :string
    add_column :spree_shipments, :height, :float, default: 0.0
    add_column :spree_shipments, :width,  :float, default: 0.0
    add_column :spree_shipments, :length, :float, default: 0.0
    add_column :spree_shipments, :weight, :float, default: 0.0


  end

end
