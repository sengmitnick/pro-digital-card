require 'rails_helper'

RSpec.describe "Teams", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { create(:user) }
  # before { sign_in_as(user) }

  describe "GET /teams" do
    let(:organization) { create(:organization, name: '测试医院') }
    let(:profile_with_dept) { create(:profile, organization: organization, department: '外科', status: 'approved') }
    let(:profile_no_dept) { create(:profile, organization: organization, department: nil, status: 'approved') }

    it "returns http success" do
      get teams_path
      expect(response).to be_success_with_view_check('index')
    end

    it "displays organization name in title" do
      get teams_path(profile_id: profile_with_dept.id)
      expect(response.body).to include('测试医院')
      expect(response.body).to include('<title')
    end

    it "shows department name for profiles with department" do
      get teams_path(profile_id: profile_with_dept.id)
      expect(response.body).to include('外科')
    end

    it "shows 核心成员 for profiles without department" do
      get teams_path(profile_id: profile_no_dept.id)
      expect(response.body).to include('核心成员')
    end
  end



end
