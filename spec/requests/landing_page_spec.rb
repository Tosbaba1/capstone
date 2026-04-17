require "rails_helper"

RSpec.describe "Landing page", type: :request do
  it "shows the public landing page at root for guests" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Read with quiet company.")
    expect(response.body).to include("Join a quiet room, read beside others, and make the habit easier to keep.")
  end

  it "routes the primary CTA to the supported auth entry point" do
    get root_path

    document = Nokogiri::HTML.parse(response.body)
    hero_primary_cta = document.at_css(".landing-hero__cta")
    final_primary_cta = document.at_css(".landing-final-cta__button")
    secondary_link = document.at_css(".landing-hero__secondary-link")

    expect(hero_primary_cta).to be_present
    expect(hero_primary_cta.text.strip).to eq("Start reading")
    expect(hero_primary_cta["href"]).to eq(new_user_session_path)

    expect(final_primary_cta).to be_present
    expect(final_primary_cta["href"]).to eq(new_user_session_path)

    expect(secondary_link).to be_present
    expect(secondary_link["href"]).to eq("#landing-how-it-works")
  end

  it "renders the landing sections in the intended order for guests" do
    get root_path
    page_text = Nokogiri::HTML.parse(response.body).text.squish

    expect(page_text).to include("How it works")
    expect(page_text).to include("Start a session")
    expect(page_text).to include("Read with others")
    expect(page_text).to include("Come back tomorrow")
    expect(page_text).to include("Why Nouvelle is different")
    expect(page_text).to include("Silent co-reading")
    expect(page_text).to include("A calm reading room, not a feed.")
    expect(page_text).to include("Ready to begin?")

    hero_index = page_text.index("Read with quiet company.")
    how_it_works_index = page_text.index("How it works")
    why_index = page_text.index("Why Nouvelle is different")
    proof_index = page_text.index("A calm reading room, not a feed.")
    final_cta_index = page_text.index("Ready to begin?")

    expect(hero_index).to be < how_it_works_index
    expect(how_it_works_index).to be < why_index
    expect(why_index).to be < proof_index
    expect(proof_index).to be < final_cta_index
  end

  it "shows a subtle live reading signal when readers are active" do
    host = create(:user)
    session = create(:session, host_user: host)
    create(:session_participant, session: session, user: host, updated_at: 5.seconds.ago)

    reader = create(:user, email: "reader@example.com", username: "reader")
    create(:session_participant, session: session, user: reader, updated_at: 4.seconds.ago)

    get root_path

    expect(response.body).to include("2 people reading now")
  end

  it "keeps signed-in readers on the existing home experience" do
    sign_in create(:user, :onboarding_complete)

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Read with people already here.")
  end
end
