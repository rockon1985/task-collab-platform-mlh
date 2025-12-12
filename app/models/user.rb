# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  first_name      :string           not null
#  last_name       :string           not null
#  role            :string           default("member"), not null
#  avatar_url      :string
#  last_login_at   :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :created_projects, class_name: 'Project', foreign_key: 'owner_id', dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :tasks, foreign_key: 'assignee_id', dependent: :nullify
  has_many :created_tasks, class_name: 'Task', foreign_key: 'creator_id', dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  validates :role, inclusion: { in: %w[admin member viewer] }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

  # Callbacks
  before_validation :normalize_email
  before_save :normalize_email
  after_create :create_welcome_activity

  # Scopes
  scope :active, -> { where('last_login_at > ?', 30.days.ago) }
  scope :admins, -> { where(role: 'admin') }

  # Instance Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    role == 'admin'
  end

  def member?
    role == 'member'
  end

  def viewer?
    role == 'viewer'
  end

  def can_manage?(project)
    admin? || project.owner_id == id || project.project_memberships.find_by(user_id: id)&.role == 'manager'
  end

  def update_last_login!
    update_column(:last_login_at, Time.current)
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def create_welcome_activity
    ActivityLog.create(
      user: self,
      action: 'user_registered',
      metadata: { email: email }
    )
  end
end
