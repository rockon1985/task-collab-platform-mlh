class TaskPolicy < ApplicationPolicy
  def show?
    project_member?
  end

  def create?
    project_member? && can_edit?
  end

  def update?
    project_member? && can_edit?
  end

  def destroy?
    user.admin? || record.creator_id == user.id || user.can_manage?(record.project)
  end

  private

  def project_member?
    user.admin? || record.project.has_member?(user)
  end

  def can_edit?
    membership = record.project.project_memberships.find_by(user_id: user.id)
    user.admin? || membership&.can_edit? || record.project.owner_id == user.id
  end
end
