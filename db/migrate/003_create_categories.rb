class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :categories }
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :status, default: 'active'
      
      t.timestamps
    end
    
    add_index :categories, [:tenant_id, :slug], unique: true
    add_index :categories, :parent_id
    add_index :categories, :status
  end
end
