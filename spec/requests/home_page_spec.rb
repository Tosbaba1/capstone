require "rails_helper"

RSpec.describe "Authenticated home", type: :request do
  it "shows a populated first-open experience for a new user" do
    sign_in create(:user)

    get home_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Live reading sessions")
    expect(response.body).to include("Popular books")
    expect(response.body).to include("Reader activity")
    expect(response.body).to include("The Vanishing Half")
    expect(response.body).to include("Nina checked in after a silent session")
    expect(response.body).not_to include("Be the first to start a session.")
    expect(response.body).not_to include("Add a book to keep it close.")
  end

  it "prioritizes the user's real active session" do
    user = create(:user)
    current_session = create(:session, host_user: user, duration: 30, mode: "structured", created_at: 3.minutes.ago)
    create(:session_participant, session: current_session, user: user, join_time: 3.minutes.ago, updated_at: 5.seconds.ago)

    other_host = create(:user, name: "Mira", username: "mira")
    other_session = create(:session, host_user: other_host, duration: 20, mode: "silent", created_at: 2.minutes.ago)
    create(:session_participant, session: other_session, user: other_host, join_time: 2.minutes.ago, updated_at: 5.seconds.ago)

    sign_in user

    get home_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Your session is live now. Start reading takes you straight back into it.")
    expect(response.body).to include(%(href="#{session_path(current_session)}"))
    expect(response.body).to include("Return to session")
    expect(response.body.index("30 min Structured session")).to be < response.body.index("20 min Silent session")
  end

  it "renders the primary and secondary home CTAs" do
    sign_in create(:user)

    get home_path

    document = Nokogiri::HTML.parse(response.body)
    hero_links = document.css(".sessions-home__hero-actions a").map { |link| [link.text.strip, link["href"]] }.to_h

    expect(hero_links["Start reading"]).to eq(new_session_path)
    expect(hero_links["Join a session"]).to eq("#live-sessions")
  end
end
