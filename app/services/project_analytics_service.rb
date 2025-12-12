# Service to handle project statistics and analytics
class ProjectAnalyticsService
  def initialize(project)
    @project = project
  end

  def statistics
    {
      total_tasks: total_tasks,
      completed_tasks: completed_tasks,
      in_progress_tasks: in_progress_tasks,
      overdue_tasks: overdue_tasks,
      completion_rate: completion_rate,
      average_completion_time: average_completion_time,
      tasks_by_priority: tasks_by_priority,
      tasks_by_status: tasks_by_status,
      member_count: member_count,
      recent_activity: recent_activity
    }
  end

  private

  attr_reader :project

  def total_tasks
    @total_tasks ||= project.tasks.count
  end

  def completed_tasks
    @completed_tasks ||= project.tasks.completed.count
  end

  def in_progress_tasks
    @in_progress_tasks ||= project.tasks.in_progress.count
  end

  def overdue_tasks
    @overdue_tasks ||= project.tasks.overdue.count
  end

  def completion_rate
    return 0 if total_tasks.zero?

    ((completed_tasks.to_f / total_tasks) * 100).round(2)
  end

  def average_completion_time
    completed = project.tasks.where.not(completed_at: nil)
    return nil if completed.empty?

    total_time = completed.sum do |task|
      task.time_to_completion || 0
    end

    (total_time / completed.count).round(2)
  end

  def tasks_by_priority
    {
      critical: project.tasks.where(priority: 'critical').count,
      high: project.tasks.where(priority: 'high').count,
      medium: project.tasks.where(priority: 'medium').count,
      low: project.tasks.where(priority: 'low').count
    }
  end

  def tasks_by_status
    {
      todo: project.tasks.todo.count,
      in_progress: project.tasks.in_progress.count,
      review: project.tasks.where(status: 'review').count,
      done: project.tasks.completed.count
    }
  end

  def member_count
    project.members.count
  end

  def recent_activity
    project.activity_logs.recent.limit(10).map do |log|
      {
        action: log.action,
        user: log.user&.full_name,
        created_at: log.created_at,
        metadata: log.metadata
      }
    end
  end
end
