FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    verified { true }
    activated { true }

    trait :unverified do
      verified { false }
    end
    
    trait :pending_activation do
      activated { false }
    end
  end
end
