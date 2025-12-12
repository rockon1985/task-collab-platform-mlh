# Background job for task assignment notifications
class TaskAssignmentNotificationJob < ApplicationJob
  queue_as :default

  def perform(task_id, user_id)
    task = Task.find(task_id)
    user = User.find(user_id)

    # In a real application, this would send an email or push notification
    Rails.logger.info("Task '#{task.title}' assigned to #{user.full_name}")

    # Example: TaskMailer.assignment_notification(task, user).deliver_later
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Task or User not found: #{e.message}")
  end
end
