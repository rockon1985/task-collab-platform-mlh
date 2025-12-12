# Service to handle task assignment logic
class TaskAssignmentService
  def initialize(task, assignee, assigner)
    @task = task
    @assignee = assignee
    @assigner = assigner
  end

  def assign
    validate_assignment!

    ActiveRecord::Base.transaction do
      @task.update!(assignee: @assignee)
      log_assignment
      send_notification
    end

    Result.success(task: @task)
  rescue ValidationError => e
    Result.failure(error: e.message)
  rescue StandardError => e
    Rails.logger.error("Task assignment failed: #{e.message}")
    Result.failure(error: 'Failed to assign task')
  end

  private

  def validate_assignment!
    raise ValidationError, 'Assignee must be a project member' unless project_member?
    raise ValidationError, 'Task already assigned to this user' if already_assigned?
  end

  def project_member?
    @task.project.has_member?(@assignee)
  end

  def already_assigned?
    @task.assignee_id == @assignee.id
  end

  def log_assignment
    ActivityLog.create!(
      task: @task,
      project: @task.project,
      user: @assigner,
      action: 'task_assigned',
      metadata: {
        task_title: @task.title,
        assignee_name: @assignee.full_name,
        assigner_name: @assigner.full_name
      }
    )
  end

  def send_notification
    TaskAssignmentNotificationJob.perform_later(@task.id, @assignee.id)
  end

  class ValidationError < StandardError; end

  class Result
    attr_reader :data, :error

    def initialize(success:, data: {}, error: nil)
      @success = success
      @data = data
      @error = error
    end

    def success?
      @success
    end

    def self.success(data)
      new(success: true, data: data)
    end

    def self.failure(error:)
      new(success: false, error: error)
    end
  end
end
