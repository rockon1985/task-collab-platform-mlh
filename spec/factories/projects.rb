FactoryBot.define do
  factory :project do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph }
    status { 'active' }
    association :owner, factory: :user

    trait :archived do
      status { 'archived' }
      archived_at { Time.current }
    end

    trait :completed do
      status { 'completed' }
    end

    trait :with_members do
      transient do
        member_count { 3 }
      end

      after(:create) do |project, evaluator|
        create_list(:project_membership, evaluator.member_count, project: project)
      end
    end

    trait :with_tasks do
      transient do
        task_count { 5 }
      end

      after(:create) do |project, evaluator|
        create_list(:task, evaluator.task_count, project: project, creator: project.owner)
      end
    end
  end
end
