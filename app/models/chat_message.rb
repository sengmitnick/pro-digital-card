class ChatMessage < ApplicationRecord
  include LlmMessageValidationConcern

  belongs_to :chat_session
  has_one :profile, through: :chat_session

  validates :role, presence: true
  validates :content, presence: true

  scope :recent, -> { order(created_at: :asc) }
  scope :by_role, ->(role) { where(role: role) }
end
