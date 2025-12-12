require 'rails_helper'

RSpec.describe "Dashboards/case studies", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { create(:user) }
  # before { sign_in_as(user) }

  describe "GET /dashboards/case_studies" do
    it "returns http success" do
      get dashboards/case_studies_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /dashboards/case_studies/:id" do
    let(:dashboards/case_study_record) { create(:dashboards/case_study) }


    it "returns http success" do
      get dashboards/case_study_path(dashboards/case_study_record)
      expect(response).to be_success_with_view_check('show')
    end
  end

  describe "GET /dashboards/case_studies/new" do
    it "returns http success" do
      get new_dashboards/case_study_path
      expect(response).to be_success_with_view_check('new')
    end
  end
  
  describe "GET /dashboards/case_studies/:id/edit" do
    let(:dashboards/case_study_record) { create(:dashboards/case_study) }


    it "returns http success" do
      get edit_dashboards/case_study_path(dashboards/case_study_record)
      expect(response).to be_success_with_view_check('edit')
    end
  end
end
