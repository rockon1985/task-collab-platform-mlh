# == Schema Information
#
# Table name: project_memberships
#
#  id         :bigint           not null, primary key
#  project_id :bigint           not null
#  user_id    :bigint           not null
#  role       :string           default("member"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :role, inclusion: { in: %w[manager member viewer] }
  validates :user_id, uniqueness: { scope: :project_id, message: 'is already a member of this project' }

  after_create :log_membership_creation
  after_destroy :log_membership_removal

  scope :managers, -> { where(role: 'manager') }
  scope :members, -> { where(role: 'member') }
  scope :viewers, -> { where(role: 'viewer') }

  def manager?
    role == 'manager'
  end

  def can_edit?
    %w[manager member].include?(role)
  end

  private

  def log_membership_creation
    ActivityLog.create(
      project: project,
      user: user,
      action: 'member_added',
      metadata: {
        project_name: project.name,
        user_name: user.full_name,
        role: role
      }
    )
  end

  def log_membership_removal
    ActivityLog.create(
      project: project,
      user: user,
      action: 'member_removed',
      metadata: {
        project_name: project.name,
        user_name: user.full_name
      }
    )
  end
end
