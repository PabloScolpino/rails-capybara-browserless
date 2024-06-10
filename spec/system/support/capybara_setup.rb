# frozen_string_literal: true

# Capybara settings (not covered by Rails system tests)

# Don't wait too long in `have_xyz` matchers
Capybara.default_max_wait_time = 2

# Normalizes whitespaces when using `has_text?` and similar matchers
Capybara.default_normalize_ws = true

# Where to store artifacts (e.g. screenshots, downloaded files, etc.)
Capybara.save_path = ENV.fetch('CAPYBARA_ARTIFACTS', './tmp/capybara')

Capybara.singleton_class.prepend(Module.new do
  attr_accessor :last_used_session

  def using_session(name, &)
    self.last_used_session = name
    super
  ensure
    self.last_used_session = nil
  end
end)

if ENV['CAPYBARA_APP_HOST']
  # Connect to the target web server to run tests
  Capybara.app_host = "http://#{ENV.fetch('CAPYBARA_APP_HOST', `hostname`.strip&.downcase || '0.0.0.0')}"
else
  # Start a puma server and connect to it
  # Make server accessible from the outside world
  CAPYBARA_SERVER_PORT = 3000
  Capybara.server_host = '0.0.0.0'
  Capybara.server_port = CAPYBARA_SERVER_PORT
  Capybara.server = :puma, { Silent: ENV.fetch('CAPYBARA_SERVER_SILENT', true) }

  Capybara.app_host = "http://#{Socket.ip_address_list.find(&:ipv4_private?)&.ip_address}:#{CAPYBARA_SERVER_PORT}"
end

Capybara.always_include_port = true
