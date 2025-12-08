class CaseStudy < ApplicationRecord
  belongs_to :profile

  validates :title, presence: true
  validates :description, presence: true

  default_scope { order(position: :asc, created_at: :desc) }

  # Auto-position new records
  before_create :set_position

  private

  def set_position
    self.position ||= (profile.case_studies.maximum(:position) || 0) + 1
  end
end
