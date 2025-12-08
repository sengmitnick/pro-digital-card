require 'rails_helper'

RSpec.describe "Admin::Profiles", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/profiles" do
    it "returns http success" do
      get admin_profiles_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end
