# Load Open Library API keys from environment variables
BOOK_SEARCH_KEY = ENV["book_search_key"]
WORKS_KEY       = ENV["works_key"]
COVERS_KEY      = ENV["covers_key"]

if Rails.env.development? || Rails.env.test?
  missing = []
  missing << "book_search_key" if BOOK_SEARCH_KEY.blank?
  missing << "works_key"       if WORKS_KEY.blank?
  missing << "covers_key"      if COVERS_KEY.blank?
  if missing.any?
    raise "Missing Open Library environment variable(s): #{missing.join(', ')}"
  end
end
