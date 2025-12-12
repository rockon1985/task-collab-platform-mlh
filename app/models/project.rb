# == Schema Information
#
# Table name: projects
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  owner_id    :bigint           not null
#  status      :string           default("active"), not null
#  archived_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Project < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User'
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :tasks, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :status, inclusion: { in: %w[active archived completed] }

  # Callbacks
  after_create :add_owner_as_manager
  after_update :log_status_change, if: :saved_change_to_status?

  # Scopes
  scope :active, -> { where(status: 'active', archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :completed, -> { where(status: 'completed') }
  scope :by_owner, ->(user_id) { where(owner_id: user_id) }

  # Instance Methods
  def archive!
    update!(status: 'archived', archived_at: Time.current)
    ActivityLog.create(
      project: self,
      user: owner,
      action: 'project_archived',
      metadata: { project_name: name }
    )
  end

  def unarchive!
    update!(status: 'active', archived_at: nil)
  end

  def progress_percentage
    return 0 if tasks.count.zero?

    (tasks.completed.count.to_f / tasks.count * 100).round(2)
  end

  def overdue_tasks_count
    tasks.overdue.count
  end

  def has_member?(user)
    owner_id == user.id || members.exists?(user.id)
  end

  private

  def add_owner_as_manager
    project_memberships.create!(user: owner, role: 'manager')
  end

  def log_status_change
    ActivityLog.create(
      project: self,
      user: owner,
      action: 'project_status_changed',
      metadata: {
        project_name: name,
        old_status: status_before_last_save,
        new_status: status
      }
    )
  end
end
