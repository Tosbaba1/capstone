require "rails_helper"

RSpec.describe "User library visibility", type: :feature do
  let(:viewer) { create(:user, name: "Maya", username: "maya") }

  before do
    login_as(viewer, scope: :user)
  end

  it "opens a public user's library from their profile and keeps navigation scoped to that library" do
    owner = create(:user, name: "Avery", username: "avery", is_private: false)
    book = create(:book, title: "Open Water")
    create(:reading, user: owner, book: book, status: "reading", is_private: false)

    visit user_path(owner)

    expect(page).to have_link("View Library", href: library_user_path(owner))

    click_link "View Library"

    expect(page).to have_current_path(library_user_path(owner))
    expect(page).to have_content("Avery's Library")
    expect(page).to have_content("Avery's public shelf")
    expect(page).to have_content("Open Water")
    expect(page).not_to have_link("Add Book")
    expect(page).not_to have_button("Edit")
    expect(page).not_to have_link("Private Shelf")
    expect(page).not_to have_link("Librarian")

    click_link "Open Water"

    expect(page).to have_link("Back to Library", href: library_user_path(owner))
  end

  it "shows an authorized private user's public library without owner-only controls" do
    owner = create(:user, name: "Lena", username: "lena", is_private: true)
    create(:followrequest, sender: viewer, recipient: owner, status: "accepted")
    visible_book = create(:book, title: "Visible Stories")
    hidden_book = create(:book, title: "Secret Stories")
    create(:reading, user: owner, book: visible_book, status: "reading", is_private: false)
    create(:reading, user: owner, book: hidden_book, status: "finished", is_private: true)

    visit user_path(owner)
    click_link "View Library"

    expect(page).to have_current_path(library_user_path(owner))
    expect(page).to have_content("Lena's Library")
    expect(page).to have_content("Visible Stories")
    expect(page).not_to have_content("Secret Stories")
    expect(page).not_to have_link("Private Shelf")
    expect(page).not_to have_link("Librarian")
    expect(page).not_to have_link("Add Book")
  end

  it "redirects unauthorized private library access back to the profile with a helpful message" do
    owner = create(:user, name: "Noah", username: "noah", is_private: true)

    visit library_user_path(owner)

    expect(page).to have_current_path(user_path(owner))
    expect(page).to have_content("This library is private. Follow Noah to view their public shelf.")
  end

  it "keeps the current user's library behavior intact" do
    public_book = create(:book, title: "Shared Book")
    private_book = create(:book, title: "Private Book")
    create(:reading, user: viewer, book: public_book, status: "reading", is_private: false)
    create(:reading, user: viewer, book: private_book, status: "reading", is_private: true)

    visit library_path(tab: "private")

    expect(page).to have_current_path(library_path(tab: "private"))
    expect(page).to have_content("Your Library")
    expect(page).to have_content("Private shelf")
    expect(page).to have_content("Private Book")
    expect(page).not_to have_content("Shared Book")
    expect(page).to have_link("Shared Shelf", href: library_path(tab: "public"))
    expect(page).to have_link("Private Shelf", href: library_path(tab: "private"))
    expect(page).to have_link("Librarian", href: library_path(tab: "ai"))
    expect(page).to have_link("Add Book")
  end
end
