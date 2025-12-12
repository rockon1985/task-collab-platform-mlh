class CommentPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    user.admin? || record.user_id == user.id
  end

  def destroy?
    user.admin? || record.user_id == user.id
  end
end
