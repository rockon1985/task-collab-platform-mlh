class CreateActivityLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_logs do |t|
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true
      t.references :task, foreign_key: true
      t.string :action, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :activity_logs, :action
    add_index :activity_logs, :created_at
    add_index :activity_logs, :metadata, using: :gin
  end
end
