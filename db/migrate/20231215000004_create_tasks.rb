class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.references :project, null: false, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: 'todo'
      t.string :priority, null: false, default: 'medium'
      t.datetime :due_date
      t.datetime :completed_at
      t.integer :position

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :priority
    add_index :tasks, :due_date
    add_index :tasks, :position
  end
end
