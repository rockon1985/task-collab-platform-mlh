# == Schema Information
#
# Table name: tasks
#
#  id          :bigint           not null, primary key
#  title       :string           not null
#  description :text
#  project_id  :bigint           not null
#  assignee_id :bigint
#  creator_id  :bigint           not null
#  status      :string           default("todo"), not null
#  priority    :string           default("medium"), not null
#  due_date    :datetime
#  completed_at :datetime
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Task < ApplicationRecord
  # Associations
  belongs_to :project
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :creator, class_name: 'User'
  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :status, inclusion: { in: %w[todo in_progress review done] }
  validates :priority, inclusion: { in: %w[low medium high critical] }
  validate :due_date_cannot_be_in_past, if: -> { due_date_changed? && due_date.present? }

  # Callbacks
  before_create :set_position
  after_update :log_status_change, if: :saved_change_to_status?
  after_update :set_completed_at, if: :saved_change_to_status?

  # Scopes
  scope :todo, -> { where(status: 'todo') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'done') }
  scope :overdue, -> { where('due_date < ? AND status != ?', Time.current, 'done') }
  scope :by_priority, -> { order(Arel.sql("CASE priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END")) }
  scope :by_position, -> { order(:position) }
  scope :assigned_to, ->(user_id) { where(assignee_id: user_id) }

  # Instance Methods
  def overdue?
    due_date.present? && due_date < Time.current && status != 'done'
  end

  def mark_as_done!
    update!(status: 'done', completed_at: Time.current)
  end

  def assign_to!(user)
    raise ArgumentError, 'User must be a project member' unless project.has_member?(user)

    update!(assignee: user)
    notify_assignment(user)
  end

  def time_to_completion
    return nil unless completed_at

    completed_at - created_at
  end

  private

  def set_position
    self.position ||= (project.tasks.maximum(:position) || 0) + 1
  end

  def due_date_cannot_be_in_past
    if due_date < Time.current
      errors.add(:due_date, "can't be in the past")
    end
  end

  def log_status_change
    ActivityLog.create(
      task: self,
      project: project,
      user: Current.user || creator,
      action: 'task_status_changed',
      metadata: {
        task_title: title,
        old_status: status_before_last_save,
        new_status: status
      }
    )
  end

  def set_completed_at
    if status == 'done' && completed_at.nil?
      update_column(:completed_at, Time.current)
    elsif status != 'done' && completed_at.present?
      update_column(:completed_at, nil)
    end
  end

  def notify_assignment(user)
    TaskAssignmentNotificationJob.perform_later(id, user.id)
  end
end
