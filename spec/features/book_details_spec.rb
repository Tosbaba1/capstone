require 'rails_helper'

RSpec.describe 'Book details', type: :feature do
  let(:user) { create(:user) }
  let(:author) { create(:author, name: 'Jane Doe') }

  before do
    login_as(user, scope: :user)
  end

  it 'shows work info and reading counts' do
    book = create(:book, title: 'Test Work', author: author)
    create_list(:reading, 2, book: book, status: 'finished')
    create_list(:reading, 1, book: book, status: 'reading')
    create_list(:reading, 3, book: book, status: 'want_to_read')

    work_response = {
      'title' => 'Test Work',
      'authors' => [{ 'name' => 'Jane Doe' }]
    }

    stub_request(:get, 'https://openlibrary.org/works/OL123W.json')
      .to_return(status: 200, body: work_response.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    visit '/books/details/OL123W'

    expect(page).to have_content('Test Work')
    expect(page).to have_content('Finished: 2')
    expect(page).to have_content('Reading: 1')
    expect(page).to have_content('Want to read: 3')
  end

  it 'fetches edition data when edition_id provided' do
    work_response = {
      'title' => 'Another Book',
      'authors' => [{ 'name' => 'Jane Doe' }]
    }
    edition_response = { 'title' => 'Another Book - First Edition' }

    stub_request(:get, 'https://openlibrary.org/works/OL456W.json')
      .to_return(status: 200, body: work_response.to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://openlibrary.org/books/OL1M.json')
      .to_return(status: 200, body: edition_response.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    visit '/books/details/OL456W?edition_id=OL1M'

    expect(page).to have_content('Another Book')
    expect(page).to have_content('Edition: Another Book - First Edition')
  end
end
