FactoryBot.define do
  factory :profile do
    association :user
    full_name { "John Doe" }
    title { "Professional Expert" }
    company { "Example Company" }
    phone { "555-1234" }
    email { "john@example.com" }
    location { "New York" }
    bio { "Professional with extensive experience" }
    specializations { ["Consulting", "Management"] }
    stats { { "years_experience" => 5, "cases_handled" => 50 } }

    trait :with_case_studies do
      after(:create) do |profile|
        create_list(:case_study, 2, profile: profile)
      end
    end

    trait :with_honors do
      after(:create) do |profile|
        create_list(:honor, 2, profile: profile)
      end
    end
  end

  # Alias for cards controller tests
  factory :card, parent: :profile
end