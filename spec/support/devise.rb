require 'devise'

RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.after(type: :feature) { Warden.test_reset! }
end
