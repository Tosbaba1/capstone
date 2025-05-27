require "rails_helper"

RSpec.describe "Unified search", type: :feature do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  scenario "search for books and import" do
    search_response = {
      "docs" => [
        {
          "title" => "Test Book",
          "author_name" => ["Jane Doe"],
          "key" => "/works/OL123W",
          "cover_i" => 111
        }
      ]
    }

    stub_request(:get, "https://openlibrary.org/search.json")
      .with(query: hash_including(q: "Test Book"))
      .to_return(status: 200, body: search_response.to_json, headers: { "Content-Type" => "application/json" })

    work_response = {
      "title" => "Test Book",
      "authors" => [ { "name" => "Jane Doe" } ],
      "description" => "Great read",
      "covers" => [111]
    }

    stub_request(:get, "https://openlibrary.org/works/OL123W.json")
      .to_return(status: 200, body: work_response.to_json, headers: { "Content-Type" => "application/json" })

    visit "/search?tab=books"
    fill_in "q", with: "Test Book"
    click_button "Search"

    expect(page).to have_content("Test Book")

    expect do
      click_button "Import", match: :first
    end.to change(Book, :count).by(1).and change(Reading, :count).by(1)

    expect(page).to have_current_path("/library")
    expect(user.readings.last.book.title).to eq("Test Book")
  end

  scenario "search for users" do
    target_user = create(:user, name: "Alice", username: "alice")

    visit "/search?tab=users"
    fill_in "q", with: "Alice"
    click_button "Search"

    expect(page).to have_content("Alice")
  end
end
