class ProjectSerializer < ApplicationSerializer
  def as_json
    base_attributes.tap do |attrs|
      attrs.merge!(detailed_attributes) if options[:detailed]
    end
  end

  private

  def base_attributes
    {
      id: object.id,
      name: object.name,
      description: object.description,
      status: object.status,
      owner: UserSerializer.new(object.owner).as_json,
      member_count: object.members.count,
      task_count: object.tasks.count,
      completed_tasks_count: object.tasks.completed.count,
      progress_percentage: object.progress_percentage,
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end

  def detailed_attributes
    {
      members: object.members.map { |m| UserSerializer.new(m).as_json },
      tasks: object.tasks.order(position: :asc, created_at: :desc).map { |t| TaskSerializer.new(t).as_json },
      overdue_tasks_count: object.overdue_tasks_count,
      archived_at: object.archived_at
    }
  end
end
