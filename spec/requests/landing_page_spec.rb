require "rails_helper"

RSpec.describe "Landing page", type: :request do
  it "shows the public landing page at root for guests" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Read… without doing it alone.")
    expect(response.body).to include("Start a reading session, join others quietly, and build a habit that actually sticks.")
  end

  it "routes the primary CTA to the supported auth entry point" do
    get root_path

    document = Nokogiri::HTML.parse(response.body)
    primary_cta = document.at_css(".landing-hero__actions a")

    expect(primary_cta).to be_present
    expect(primary_cta.text.strip).to eq("Start reading")
    expect(primary_cta["href"]).to eq(new_user_session_path)
  end

  it "renders the key landing sections for guests" do
    get root_path
    page_text = Nokogiri::HTML.parse(response.body).text

    expect(page_text).to include("How it works")
    expect(page_text).to include("Start a session")
    expect(page_text).to include("Read with others")
    expect(page_text).to include("Come back tomorrow")
    expect(page_text).to include("Reading doesn't have to be a solo activity.")
    expect(page_text).to include("Ready to begin?")
  end

  it "shows a subtle live reading signal when readers are active" do
    host = create(:user)
    session = create(:session, host_user: host)
    create(:session_participant, session: session, user: host, updated_at: 5.seconds.ago)

    reader = create(:user, email: "reader@example.com", username: "reader")
    create(:session_participant, session: session, user: reader, updated_at: 4.seconds.ago)

    get root_path

    expect(response.body).to include("2 people are reading right now")
  end

  it "keeps signed-in readers on the existing home experience" do
    sign_in create(:user)

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Read with people already here.")
  end
end
