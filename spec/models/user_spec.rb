require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:created_projects).class_name('Project').dependent(:destroy) }
    it { should have_many(:project_memberships).dependent(:destroy) }
    it { should have_many(:projects).through(:project_memberships) }
    it { should have_many(:tasks).dependent(:nullify) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:activity_logs).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_inclusion_of(:role).in_array(%w[admin member viewer]) }
    it { should have_secure_password }
  end

  describe 'callbacks' do
    it 'normalizes email before save' do
      user = create(:user, email: 'TEST@EXAMPLE.COM  ')
      expect(user.reload.email).to eq('test@example.com')
    end

    it 'creates welcome activity after creation' do
      expect {
        create(:user)
      }.to change(ActivityLog, :count).by(1)
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns users who logged in within 30 days' do
        active_user = create(:user, last_login_at: 10.days.ago)
        inactive_user = create(:user, last_login_at: 40.days.ago)

        expect(User.active).to include(active_user)
        expect(User.active).not_to include(inactive_user)
      end
    end

    describe '.admins' do
      it 'returns only admin users' do
        admin = create(:user, :admin)
        member = create(:user)

        expect(User.admins).to include(admin)
        expect(User.admins).not_to include(member)
      end
    end
  end

  describe '#full_name' do
    it 'returns first and last name combined' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe '#admin?' do
    it 'returns true for admin users' do
      admin = build(:user, :admin)
      expect(admin.admin?).to be true
    end

    it 'returns false for non-admin users' do
      member = build(:user)
      expect(member.admin?).to be false
    end
  end

  describe '#can_manage?' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }

    context 'when user is admin' do
      it 'returns true' do
        admin = create(:user, :admin)
        expect(admin.can_manage?(project)).to be true
      end
    end

    context 'when user is project owner' do
      it 'returns true' do
        expect(project.owner.can_manage?(project)).to be true
      end
    end

    context 'when user is project manager' do
      it 'returns true' do
        create(:project_membership, :manager, user: user, project: project)
        expect(user.can_manage?(project)).to be true
      end
    end

    context 'when user is regular member' do
      it 'returns false' do
        create(:project_membership, user: user, project: project)
        expect(user.can_manage?(project)).to be false
      end
    end
  end

  describe '#update_last_login!' do
    it 'updates last_login_at timestamp' do
      user = create(:user, last_login_at: nil)
      expect {
        user.update_last_login!
      }.to change { user.reload.last_login_at }.from(nil)
    end
  end
end
