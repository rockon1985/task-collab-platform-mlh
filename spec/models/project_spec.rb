require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should belong_to(:owner).class_name('User') }
    it { should have_many(:project_memberships).dependent(:destroy) }
    it { should have_many(:members).through(:project_memberships) }
    it { should have_many(:tasks).dependent(:destroy) }
    it { should have_many(:activity_logs).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(100) }
    it { should validate_inclusion_of(:status).in_array(%w[active archived completed]) }
  end

  describe 'callbacks' do
    it 'adds owner as manager after creation' do
      project = create(:project)
      membership = project.project_memberships.find_by(user: project.owner)

      expect(membership).to be_present
      expect(membership.role).to eq('manager')
    end

    it 'logs status change after update' do
      project = create(:project, status: 'active')

      expect {
        project.update!(status: 'completed')
      }.to change(ActivityLog, :count).by(1)

      log = ActivityLog.last
      expect(log.action).to eq('project_status_changed')
      expect(log.metadata['old_status']).to eq('active')
      expect(log.metadata['new_status']).to eq('completed')
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active, non-archived projects' do
        active = create(:project, status: 'active')
        archived = create(:project, :archived)

        expect(Project.active).to include(active)
        expect(Project.active).not_to include(archived)
      end
    end

    describe '.by_owner' do
      it 'returns projects by specific owner' do
        user = create(:user)
        project = create(:project, owner: user)
        other_project = create(:project)

        expect(Project.by_owner(user.id)).to include(project)
        expect(Project.by_owner(user.id)).not_to include(other_project)
      end
    end
  end

  describe '#archive!' do
    let(:project) { create(:project) }

    it 'sets status to archived' do
      project.archive!
      expect(project.reload.status).to eq('archived')
    end

    it 'sets archived_at timestamp' do
      project.archive!
      expect(project.reload.archived_at).to be_present
    end

    it 'creates activity log' do
      expect {
        project.archive!
      }.to change(ActivityLog, :count).by(1)
    end
  end

  describe '#progress_percentage' do
    let(:project) { create(:project) }

    it 'returns 0 when no tasks exist' do
      expect(project.progress_percentage).to eq(0)
    end

    it 'calculates percentage correctly' do
      create_list(:task, 3, project: project, creator: project.owner)
      create_list(:task, 2, :completed, project: project, creator: project.owner)

      # 2 completed out of 5 total = 40%
      expect(project.progress_percentage).to eq(40.0)
    end
  end

  describe '#has_member?' do
    let(:project) { create(:project) }
    let(:member) { create(:user) }
    let(:non_member) { create(:user) }

    before do
      create(:project_membership, project: project, user: member)
    end

    it 'returns true for owner' do
      expect(project.has_member?(project.owner)).to be true
    end

    it 'returns true for members' do
      expect(project.has_member?(member)).to be true
    end

    it 'returns false for non-members' do
      expect(project.has_member?(non_member)).to be false
    end
  end
end
