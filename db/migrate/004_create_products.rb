class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :sku, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :weight, precision: 8, scale: 2
      t.string :status, default: 'active'
      
      t.timestamps
    end
    
    add_index :products, [:tenant_id, :slug], unique: true
    add_index :products, [:tenant_id, :sku], unique: true
    add_index :products, :category_id
    add_index :products, :status
    add_index :products, :price
  end
end
