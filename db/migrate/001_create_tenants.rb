class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.string :status, default: 'active'
      
      t.timestamps
    end
    
    add_index :tenants, :subdomain, unique: true
    add_index :tenants, :status
  end
end
