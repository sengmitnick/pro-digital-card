FactoryBot.define do
  factory :honor do

    association :profile
    title { "MyString" }
    organization { "MyString" }
    date { "MyString" }
    description { "MyText" }
    icon_name { "MyString" }

  end
end
