FactoryBot.define do
  factory :case_study do

    association :profile
    title { "MyString" }
    category { "MyString" }
    date { "MyString" }
    description { "MyText" }
    position { 1 }

  end
end
