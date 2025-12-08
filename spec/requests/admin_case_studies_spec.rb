require 'rails_helper'

RSpec.describe "Admin::CaseStudies", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/case_studies" do
    it "returns http success" do
      get admin_case_studies_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end
