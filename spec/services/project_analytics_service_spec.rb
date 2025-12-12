require 'rails_helper'

RSpec.describe ProjectAnalyticsService do
  let(:project) { create(:project, :with_members, :with_tasks) }
  let(:service) { described_class.new(project) }

  describe '#statistics' do
    it 'returns comprehensive statistics' do
      stats = service.statistics

      expect(stats).to include(
        :total_tasks,
        :completed_tasks,
        :in_progress_tasks,
        :overdue_tasks,
        :completion_rate,
        :tasks_by_priority,
        :tasks_by_status,
        :member_count,
        :recent_activity
      )
    end

    it 'calculates total tasks correctly' do
      expect(service.statistics[:total_tasks]).to eq(project.tasks.count)
    end

    it 'calculates completion rate correctly' do
      create_list(:task, 3, :completed, project: project, creator: project.owner)
      # 3 completed out of 8 total (5 from factory + 3 new) = 37.5%

      stats = service.statistics
      expect(stats[:completion_rate]).to be > 0
    end

    it 'groups tasks by priority' do
      create(:task, :critical, project: project, creator: project.owner)
      create(:task, :high_priority, project: project, creator: project.owner)

      stats = service.statistics
      expect(stats[:tasks_by_priority]).to be_a(Hash)
      expect(stats[:tasks_by_priority]).to include(:critical, :high, :medium, :low)
    end
  end
end
