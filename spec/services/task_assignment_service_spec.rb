require 'rails_helper'

RSpec.describe TaskAssignmentService do
  let(:project) { create(:project) }
  let(:task) { create(:task, project: project, creator: project.owner) }
  let(:assignee) { create(:user) }
  let(:assigner) { project.owner }
  let(:service) { described_class.new(task, assignee, assigner) }

  before do
    create(:project_membership, project: project, user: assignee)
  end

  describe '#assign' do
    context 'with valid assignment' do
      it 'assigns task to user' do
        result = service.assign

        expect(result.success?).to be true
        expect(task.reload.assignee).to eq(assignee)
      end

      it 'creates activity log' do
        expect {
          service.assign
        }.to change(ActivityLog, :count).by(1)

        log = ActivityLog.last
        expect(log.action).to eq('task_assigned')
        expect(log.metadata['assignee_name']).to eq(assignee.full_name)
      end

      it 'enqueues notification job' do
        expect {
          service.assign
        }.to have_enqueued_job(TaskAssignmentNotificationJob)
      end
    end

    context 'with invalid assignment' do
      let(:non_member) { create(:user) }
      let(:service) { described_class.new(task, non_member, assigner) }

      it 'fails when assignee is not a project member' do
        result = service.assign

        expect(result.success?).to be false
        expect(result.error).to include('project member')
      end

      it 'does not change assignee' do
        expect {
          service.assign
        }.not_to change { task.reload.assignee }
      end
    end

    context 'when task is already assigned to user' do
      before do
        task.update!(assignee: assignee)
      end

      it 'fails with appropriate error' do
        result = service.assign

        expect(result.success?).to be false
        expect(result.error).to include('already assigned')
      end
    end
  end
end
