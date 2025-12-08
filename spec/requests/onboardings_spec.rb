require 'rails_helper'

RSpec.describe "Onboardings", type: :request do

  let(:user) { create(:user) }
  before { sign_in_as(user) }

  describe "GET /onboardings" do
    it "returns http success" do
      get onboardings_path
      expect(response).to be_success_with_view_check('index')
    end
  end



end
