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

  it 'shows details from search results and allows importing' do
    search_response = {
      'docs' => [
        {
          'title' => 'Search Book',
          'author_name' => ['Jane Doe'],
          'key' => '/works/OL789W',
          'edition_key' => ['OL2M']
        }
      ]
    }

    stub_request(:get, 'https://openlibrary.org/search.json')
      .with(query: hash_including(q: 'Search Book'))
      .to_return(status: 200, body: search_response.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    work_response = {
      'title' => 'Search Book',
      'authors' => [{ 'name' => 'Jane Doe' }],
      'number_of_pages' => 321
    }

    edition_response = {
      'title' => 'Search Book - Second Edition',
      'number_of_pages' => 321
    }

    stub_request(:get, 'https://openlibrary.org/works/OL789W.json')
      .to_return(status: 200, body: work_response.to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://openlibrary.org/books/OL2M.json')
      .to_return(status: 200, body: edition_response.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    visit '/search?tab=books&q=Search+Book'
    click_link 'Details', match: :first

    expect(page).to have_content('Jane Doe')
    expect(page).to have_content('Page length: 321')
    expect(page).to have_content('Edition: Search Book - Second Edition')
    expect(page).to have_content('Finished: 0')
    expect(page).to have_content('Reading: 0')
    expect(page).to have_content('Want to read: 0')

    expect do
      click_button 'Add to Library'
    end.to change(Book, :count).by(1).and change(Reading, :count).by(1)

    visit '/books/details/OL789W?edition_id=OL2M'
    expect(page).to have_content('Want to read: 1')
  end
end
