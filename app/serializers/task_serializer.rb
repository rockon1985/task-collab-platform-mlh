class TaskSerializer < ApplicationSerializer
  def as_json
    base_attributes.tap do |attrs|
      attrs.merge!(detailed_attributes) if options[:detailed]
    end
  end

  private

  def base_attributes
    {
      id: object.id,
      title: object.title,
      description: object.description,
      status: object.status,
      priority: object.priority,
      due_date: object.due_date,
      position: object.position,
      overdue: object.overdue?,
      assignee: object.assignee ? UserSerializer.new(object.assignee).as_json : nil,
      creator: UserSerializer.new(object.creator).as_json,
      created_at: object.created_at,
      updated_at: object.updated_at,
      completed_at: object.completed_at
    }
  end

  def detailed_attributes
    {
      project: {
        id: object.project.id,
        name: object.project.name
      },
      comments_count: object.comments.count,
      time_to_completion: object.time_to_completion
    }
  end
end
