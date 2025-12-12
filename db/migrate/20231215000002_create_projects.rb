class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: 'active'
      t.datetime :archived_at

      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, :archived_at
  end
end
