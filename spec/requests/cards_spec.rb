require 'rails_helper'

RSpec.describe "Cards", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { create(:user) }
  # before { sign_in_as(user) }


  describe "GET /cards/:id" do
    let(:card_record) { create(:card) }


    it "returns http success" do
      get card_path(card_record)
      expect(response).to be_success_with_view_check('show')
    end
  end


end
