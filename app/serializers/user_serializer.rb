class UserSerializer < ApplicationSerializer
  def as_json
    {
      id: object.id,
      email: object.email,
      first_name: object.first_name,
      last_name: object.last_name,
      full_name: object.full_name,
      role: object.role,
      avatar_url: object.avatar_url,
      last_login_at: object.last_login_at,
      created_at: object.created_at
    }
  end
end
