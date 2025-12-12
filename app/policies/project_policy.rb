class ProjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.owner_id == user.id || record.has_member?(user)
  end

  def create?
    true
  end

  def update?
    user.admin? || user.can_manage?(record)
  end

  def destroy?
    user.admin? || record.owner_id == user.id
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:project_memberships)
             .where(project_memberships: { user_id: user.id })
             .or(scope.where(owner_id: user.id))
      end
    end
  end
end
