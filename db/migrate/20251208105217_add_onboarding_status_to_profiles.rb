class AddOnboardingStatusToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :onboarding_completed, :boolean, default: false
    add_column :profiles, :onboarding_step, :string
    add_column :profiles, :onboarding_data, :jsonb

  end
end
