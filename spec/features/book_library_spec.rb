require 'rails_helper'

RSpec.describe 'Book management', type: :feature do
  let(:user) { create(:user) }
  let(:author) { create(:author) }

  before do
    login_as(user, scope: :user)
  end

  it 'allows a user to create a book and see it in their library' do
    visit '/books'

    fill_in 'Title', with: 'My Awesome Book'
    fill_in 'Image url', with: 'http://example.com/test.jpg'
    fill_in 'Author', with: author.id
    fill_in 'Description', with: 'A great read'
    fill_in 'Page length', with: 150
    fill_in 'Year', with: 2021
    fill_in 'Genre', with: 'Fiction'

    click_button 'Create book'

    expect(page).to have_content('Book created successfully')

    visit '/library'
    expect(page).to have_content('My Awesome Book')
  end
end
