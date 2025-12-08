class ChatSession < ApplicationRecord
  belongs_to :profile
  has_many :chat_messages, dependent: :destroy

  validates :visitor_name, presence: true

  scope :recent, -> { order(started_at: :desc) }
  scope :active, -> { where(ended_at: nil) }
  scope :completed, -> { where.not(ended_at: nil) }

  def active?
    ended_at.nil?
  end

  def duration
    return nil unless ended_at
    ended_at - started_at
  end
end
