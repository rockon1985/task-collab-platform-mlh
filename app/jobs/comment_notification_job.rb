# Background job for comment notifications
class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find(comment_id)
    task = comment.task

    # Notify task assignee and project members
    recipients = [task.assignee, task.creator].compact.uniq
    recipients.each do |recipient|
      next if recipient.id == comment.user_id # Don't notify the commenter

      Rails.logger.info("Notifying #{recipient.full_name} about new comment on '#{task.title}'")
      # Example: CommentMailer.new_comment_notification(comment, recipient).deliver_later
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Comment not found: #{e.message}")
  end
end
