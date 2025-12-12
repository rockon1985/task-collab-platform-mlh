require 'rails_helper'

RSpec.describe CommentNotificationJob, type: :job do
  describe '#perform' do
    let(:project) { create(:project, owner: owner) }
    let(:owner) { create(:user, first_name: 'Project', last_name: 'Owner') }
    let(:assignee) { create(:user, first_name: 'Task', last_name: 'Assignee') }
    let(:creator) { create(:user, first_name: 'Task', last_name: 'Creator') }
    let(:commenter) { create(:user, first_name: 'Comment', last_name: 'Author') }
    let(:task) { create(:task, project: project, creator: creator, assignee: assignee, title: 'Important Task') }
    let(:comment) { create(:comment, task: task, user: commenter, content: 'Great work!') }

    context 'when comment exists' do
      it 'logs notification for each recipient' do
        allow(Rails.logger).to receive(:info)

        described_class.perform_now(comment.id)

        expect(Rails.logger).to have_received(:info).with(/Notifying.*Task Creator/)
        expect(Rails.logger).to have_received(:info).with(/Notifying.*Task Assignee/)
      end

      it 'does not notify the commenter' do
        comment_by_assignee = create(:comment, task: task, user: assignee, content: 'Self comment')

        allow(Rails.logger).to receive(:info)

        described_class.perform_now(comment_by_assignee.id)

        expect(Rails.logger).to have_received(:info).with(/Notifying.*Task Creator/)
        expect(Rails.logger).not_to have_received(:info).with(/Notifying.*Task Assignee/)
      end

      it 'notifies unique recipients only' do
        task_with_same_creator_and_assignee = create(:task, project: project, creator: creator, assignee: creator)
        comment_on_self_task = create(:comment, task: task_with_same_creator_and_assignee, user: commenter)

        allow(Rails.logger).to receive(:info)

        described_class.perform_now(comment_on_self_task.id)

        expect(Rails.logger).to have_received(:info).once.with(/Notifying.*Task Creator/)
      end

      it 'handles task without assignee' do
        task_without_assignee = create(:task, project: project, creator: creator, assignee: nil)
        comment_on_unassigned = create(:comment, task: task_without_assignee, user: commenter)

        allow(Rails.logger).to receive(:info)

        described_class.perform_now(comment_on_unassigned.id)

        expect(Rails.logger).to have_received(:info).once.with(/Notifying.*Task Creator/)
      end
    end

    context 'when comment does not exist' do
      it 'logs an error' do
        allow(Rails.logger).to receive(:error)

        described_class.perform_now(99999)

        expect(Rails.logger).to have_received(:error).with(/Comment not found/)
      end
    end
  end
end
