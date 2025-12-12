# == Schema Information
#
# Table name: activity_logs
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  project_id :bigint
#  task_id    :bigint
#  action     :string           not null
#  metadata   :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :project, optional: true
  belongs_to :task, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_project, ->(project_id) { where(project_id: project_id) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_task, ->(task_id) { where(task_id: task_id) }

  # Class method to log activity
  def self.log_action(action:, user: nil, project: nil, task: nil, metadata: {})
    create(
      action: action,
      user: user,
      project: project,
      task: task,
      metadata: metadata
    )
  end
end
