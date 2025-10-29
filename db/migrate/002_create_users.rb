class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :password_digest, null: false
      t.string :role, default: 'user'
      t.string :status, default: 'active'
      
      t.timestamps
    end
    
    add_index :users, [:tenant_id, :email], unique: true
    add_index :users, :role
    add_index :users, :status
  end
end
