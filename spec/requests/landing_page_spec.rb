require "rails_helper"

RSpec.describe "Landing page", type: :request do
  it "shows the public landing page at root for guests" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Find your place to begin")
    expect(response.body).to include("Read quietly alongside others")
  end

  it "routes the primary CTA to the supported auth entry point" do
    get root_path

    expect(response.body).to include(%(href="#{new_user_session_path}"))
    expect(response.body).to include("Start reading")
  end

  it "keeps signed-in readers on the existing home experience" do
    sign_in create(:user)

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Start reading now.")
  end
end
