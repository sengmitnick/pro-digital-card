FactoryBot.define do
  factory :chat_message do

    association :chat_session
    role { "MyString" }
    content { "MyText" }

  end
end
