class CommentSerializer < ApplicationSerializer
  def as_json
    {
      id: object.id,
      content: object.content,
      user: UserSerializer.new(object.user).as_json,
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
