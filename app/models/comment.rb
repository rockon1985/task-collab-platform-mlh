# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  task_id    :bigint           not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :content, presence: true, length: { minimum: 1, maximum: 2000 }

  after_create :notify_task_watchers
  after_create :log_comment_creation

  scope :recent, -> { order(created_at: :desc) }

  private

  def notify_task_watchers
    CommentNotificationJob.perform_later(id)
  end

  def log_comment_creation
    ActivityLog.create(
      task: task,
      project: task.project,
      user: user,
      action: 'comment_added',
      metadata: {
        task_title: task.title,
        comment_preview: content.truncate(50)
      }
    )
  end
end
