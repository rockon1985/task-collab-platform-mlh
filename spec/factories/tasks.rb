FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence(word_count: 5) }
    description { Faker::Lorem.paragraph }
    status { 'todo' }
    priority { 'medium' }
    due_date { 1.week.from_now }
    association :project
    association :creator, factory: :user

    trait :assigned do
      association :assignee, factory: :user
    end

    trait :in_progress do
      status { 'in_progress' }
    end

    trait :completed do
      status { 'done' }
      completed_at { Time.current }
    end

    trait :overdue do
      due_date { 1.week.from_now }
      status { 'todo' }

      after(:create) do |task|
        task.update_column(:due_date, 1.day.ago)
      end
    end

    trait :high_priority do
      priority { 'high' }
    end

    trait :critical do
      priority { 'critical' }
    end

    trait :with_comments do
      transient do
        comment_count { 3 }
      end

      after(:create) do |task, evaluator|
        create_list(:comment, evaluator.comment_count, task: task)
      end
    end
  end
end
