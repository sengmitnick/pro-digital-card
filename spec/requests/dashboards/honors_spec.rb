require 'rails_helper'

RSpec.describe "Dashboards/honors", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { create(:user) }
  # before { sign_in_as(user) }

  describe "GET /dashboards/honors" do
    it "returns http success" do
      get dashboards/honors_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /dashboards/honors/:id" do
    let(:dashboards/honor_record) { create(:dashboards/honor) }


    it "returns http success" do
      get dashboards/honor_path(dashboards/honor_record)
      expect(response).to be_success_with_view_check('show')
    end
  end

  describe "GET /dashboards/honors/new" do
    it "returns http success" do
      get new_dashboards/honor_path
      expect(response).to be_success_with_view_check('new')
    end
  end
  
  describe "GET /dashboards/honors/:id/edit" do
    let(:dashboards/honor_record) { create(:dashboards/honor) }


    it "returns http success" do
      get edit_dashboards/honor_path(dashboards/honor_record)
      expect(response).to be_success_with_view_check('edit')
    end
  end
end
