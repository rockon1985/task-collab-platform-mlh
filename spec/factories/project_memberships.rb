FactoryBot.define do
  factory :project_membership do
    association :project
    association :user
    role { 'member' }

    trait :manager do
      role { 'manager' }
    end

    trait :viewer do
      role { 'viewer' }
    end
  end
end
