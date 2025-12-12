require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:assignee).optional }
    it { should belong_to(:creator) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:activity_logs).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(200) }
    it { should validate_inclusion_of(:status).in_array(%w[todo in_progress review done]) }
    it { should validate_inclusion_of(:priority).in_array(%w[low medium high critical]) }

    describe 'due_date validation' do
      it 'allows due dates in the future' do
        task = build(:task, due_date: 1.day.from_now)
        expect(task).to be_valid
      end

      it 'rejects due dates in the past for new records' do
        task = build(:task, due_date: 1.day.ago)
        expect(task).not_to be_valid
        expect(task.errors[:due_date]).to include("can't be in the past")
      end
    end
  end

  describe 'callbacks' do
    let(:project) { create(:project) }

    it 'sets position before creation' do
      task1 = create(:task, project: project, creator: project.owner)
      task2 = create(:task, project: project, creator: project.owner)

      expect(task2.position).to eq(task1.position + 1)
    end

    it 'sets completed_at when status changes to done' do
      task = create(:task, status: 'todo')

      task.update!(status: 'done')
      expect(task.reload.completed_at).to be_present
    end

    it 'clears completed_at when status changes from done' do
      task = create(:task, :completed)

      task.update!(status: 'in_progress')
      expect(task.reload.completed_at).to be_nil
    end
  end

  describe 'scopes' do
    let(:project) { create(:project) }

    before do
      create(:task, status: 'todo', project: project, creator: project.owner)
      create(:task, status: 'in_progress', project: project, creator: project.owner)
      create(:task, :completed, project: project, creator: project.owner)
      create(:task, :overdue, project: project, creator: project.owner)
    end

    it 'filters by status' do
      expect(Task.todo.count).to eq(2) # todo + overdue
      expect(Task.in_progress.count).to eq(1)
      expect(Task.completed.count).to eq(1)
    end

    it 'finds overdue tasks' do
      expect(Task.overdue.count).to eq(1)
    end

    it 'sorts by priority' do
      critical = create(:task, :critical, project: project, creator: project.owner)
      low = create(:task, priority: 'low', project: project, creator: project.owner)

      expect(Task.by_priority.first).to eq(critical)
      expect(Task.by_priority.last).to eq(low)
    end
  end

  describe '#overdue?' do
    it 'returns true for past due date and not done' do
      task = build(:task, :overdue)
      expect(task.overdue?).to be true
    end

    it 'returns false for completed tasks' do
      task = build(:task, due_date: 1.day.ago, status: 'done')
      expect(task.overdue?).to be false
    end

    it 'returns false for future due date' do
      task = build(:task, due_date: 1.day.from_now)
      expect(task.overdue?).to be false
    end
  end

  describe '#mark_as_done!' do
    it 'updates status to done' do
      task = create(:task, status: 'in_progress')
      task.mark_as_done!

      expect(task.reload.status).to eq('done')
      expect(task.completed_at).to be_present
    end
  end

  describe '#time_to_completion' do
    it 'returns nil for incomplete tasks' do
      task = create(:task)
      expect(task.time_to_completion).to be_nil
    end

    it 'calculates time difference for completed tasks' do
      task = create(:task, :completed)
      expect(task.time_to_completion).to be > 0
    end
  end
end
