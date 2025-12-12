class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :role, null: false, default: 'member'
      t.string :avatar_url
      t.datetime :last_login_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
