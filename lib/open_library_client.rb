class OpenLibraryClient
  BASE_SEARCH_URL = 'https://openlibrary.org/search.json'
  BASE_WORKS_URL  = 'https://openlibrary.org/works'
  BASE_BOOKS_URL  = 'https://openlibrary.org/books'
  BASE_COVER_URL  = 'https://covers.openlibrary.org/b/id'

  def self.search_books(query)
    response = HTTP.get(BASE_SEARCH_URL, params: { q: query })
    JSON.parse(response.to_s)
  end

  def self.fetch_work(work_id)
    response = HTTP.get("#{BASE_WORKS_URL}/#{work_id}.json")
    JSON.parse(response.to_s)
  end

  def self.fetch_edition(edition_id)
    response = HTTP.get("#{BASE_BOOKS_URL}/#{edition_id}.json")
    JSON.parse(response.to_s)
  end

  def self.cover_url(cover_id, size)
    "#{BASE_COVER_URL}/#{cover_id}-#{size}.jpg"
  end
end
