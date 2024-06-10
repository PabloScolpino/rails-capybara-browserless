# frozen_string_literal: true

# Load general RSpec Rails configuration
require 'rails_helper'

# Load configuration files and helpers
Dir[File.join(__dir__, 'system/support/**/*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  # config.include Warden::Test::Helpers, type: :system
end
