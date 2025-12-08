FactoryBot.define do
  factory :chat_session do

    association :profile
    visitor_name { "MyString" }
    visitor_email { "MyString" }
    started_at { Time.current }
    ended_at { Time.current }

  end
end
