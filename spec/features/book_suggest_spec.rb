require "rails_helper"

RSpec.describe "Book suggestions", type: :feature, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  it "displays suggestions while typing" do
    stub_request(:get, "http://www.example.com/books/suggest")
      .with(query: hash_including(q: "Har"))
      .to_return(status: 200, body: [{ title: "Harry Potter" }].to_json,
                 headers: { "Content-Type" => "application/json" })

    visit "/search?tab=books"

    fill_in "q", with: "Har"

    expect(page).to have_selector("datalist option[value='Harry Potter']")
  end
end
