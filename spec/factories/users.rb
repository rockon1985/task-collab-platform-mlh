FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { 'member' }

    trait :admin do
      role { 'admin' }
    end

    trait :viewer do
      role { 'viewer' }
    end

    trait :with_avatar do
      avatar_url { Faker::Avatar.image }
    end
  end
end
