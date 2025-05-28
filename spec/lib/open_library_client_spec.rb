require 'rails_helper'

RSpec.describe OpenLibraryClient do
  describe '.fetch_edition' do
    it 'returns parsed JSON for the requested edition' do
      edition_id = 'OL123M'
      body = { 'title' => 'Edition Title' }.to_json

      stub_request(:get, "https://openlibrary.org/books/#{edition_id}.json")
        .to_return(status: 200, body: body, headers: { 'Content-Type' => 'application/json' })

      result = described_class.fetch_edition(edition_id)
      expect(result['title']).to eq('Edition Title')
    end
  end
end
