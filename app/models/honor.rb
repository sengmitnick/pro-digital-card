class Honor < ApplicationRecord
  belongs_to :profile

  validates :title, presence: true
  validates :organization, presence: true

  default_scope { order(date: :desc, created_at: :desc) }
end
