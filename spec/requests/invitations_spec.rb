require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  let!(:organization) { FactoryBot.create(:organization, name: "测试医院") }

  describe "GET /invitation/new" do
    it "renders invitation form with valid token" do
      get new_invitation_path, params: { token: organization.invite_token }
      expect(response).to have_http_status(:success)
    end
    
    it "redirects when token is missing" do
      get new_invitation_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to match(/邀请链接无效/)
    end
    
    it "redirects when token is invalid" do
      get new_invitation_path, params: { token: 'invalid_token' }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to match(/邀请链接无效/)
    end
  end

  describe "POST /invitation" do
    let(:valid_params) do
      {
        token: organization.invite_token,
        user: {
          email: "newmember@example.com",
          password: "password123",
          password_confirmation: "password123",
          profile_attributes: {
            full_name: "张三丰",
            title: "主任医师",
            department: "内科",
            bio: "从事内科临床工作20年"
          }
        }
      }
    end

    it "creates a new user with pending activation" do
      expect {
        post invitation_path, params: valid_params
      }.to change(User, :count).by(1)
        .and change(Profile, :count).by(1)

      user = User.last
      expect(user.activated).to eq(false)
      expect(user.verified).to eq(false)
      expect(user.name).to eq("newmember") # auto-generated from email
      expect(user.profile.status).to eq("pending")
      expect(user.profile.organization_id).to eq(organization.id)
    end

    it "prevents unactivated user from logging in" do
      post invitation_path, params: valid_params
      user = User.last

      post sign_in_path, params: {
        user: {
          email: user.email,
          password: "password123"
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(response.location).to include(sign_in_path)
      follow_redirect!
      expect(response.body).to match(/尚未激活/)
    end

    it "allows login after profile approval" do
      post invitation_path, params: valid_params
      user = User.last
      profile = user.profile

      # 管理员审核通过
      profile.approve!
      user.reload

      expect(user.activated).to eq(true)
      expect(profile.status).to eq("approved")

      # 现在可以登录
      post sign_in_path, params: {
        user: {
          email: user.email,
          password: "password123"
        }
      }

      expect(response).to redirect_to(root_path)
    end
  end
end
