class CreateProjectMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :project_memberships do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: 'member'

      t.timestamps
    end

    add_index :project_memberships, [:project_id, :user_id], unique: true
    add_index :project_memberships, :role
  end
end
