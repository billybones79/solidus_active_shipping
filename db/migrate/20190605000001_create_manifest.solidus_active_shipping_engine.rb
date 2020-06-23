class CreateManifest < ActiveRecord::Migration[4.2]
  def up
    create_table :spree_pws_shipping_manifests do |t|
      t.string :state
      t.string :response
      t.string :name
      t.string :manifest_url
      t.timestamps null: false
    end

    create_table :spree_shipping_groups do |t|
      t.string :name
      t.timestamps null: false
      #don't even care
      t.integer :pws_shipping_manifest_id
    end
  end

  def down
    drop_table :spree_shipping_manifests
    drop_table :spree_shipping_groups
  end
end
