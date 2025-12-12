require 'rails_helper'

RSpec.describe TaskAssignmentNotificationJob, type: :job do
  describe '#perform' do
    let(:project) { create(:project, owner: owner) }
    let(:owner) { create(:user) }
    let(:assignee) { create(:user, first_name: 'John', last_name: 'Doe') }
    let(:task) { create(:task, project: project, creator: owner, title: 'New Feature') }

    context 'when task and user exist' do
      it 'logs the assignment notification' do
        allow(Rails.logger).to receive(:info)

        described_class.perform_now(task.id, assignee.id)

        expect(Rails.logger).to have_received(:info).with("Task 'New Feature' assigned to John Doe")
      end
    end

    context 'when task does not exist' do
      it 'logs an error' do
        allow(Rails.logger).to receive(:error)

        described_class.perform_now(99999, assignee.id)

        expect(Rails.logger).to have_received(:error).with(/Task or User not found/)
      end
    end

    context 'when user does not exist' do
      it 'logs an error' do
        allow(Rails.logger).to receive(:error)

        described_class.perform_now(task.id, 99999)

        expect(Rails.logger).to have_received(:error).with(/Task or User not found/)
      end
    end

    context 'when both task and user do not exist' do
      it 'logs an error' do
        allow(Rails.logger).to receive(:error)

        described_class.perform_now(99999, 99999)

        expect(Rails.logger).to have_received(:error).with(/Task or User not found/)
      end
    end
  end
end
