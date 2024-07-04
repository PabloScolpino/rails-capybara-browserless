# frozen_string_literal: true

# Cuprite is a modern Capybara driver which uses Chrome CDP API
# instead of Selenium & co.
# See https://github.com/rubycdp/cuprite

REMOTE_CHROME_URL = ENV.fetch('CHROME_URL')
REMOTE_CHROME_HOST, REMOTE_CHROME_PORT =
  if REMOTE_CHROME_URL
    URI.parse(REMOTE_CHROME_URL).then do |uri|
      [uri.host, uri.port]
    end
  end

# Check whether the remote chrome is running.
remote_chrome =
  begin
    if REMOTE_CHROME_URL.nil?
      false
    else
      Socket.tcp(REMOTE_CHROME_HOST, REMOTE_CHROME_PORT, connect_timeout: 1).close
      true
    end
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
    false
  end

remote_options = remote_chrome ? { ws_url: REMOTE_CHROME_URL } : {}

require 'capybara/cuprite'

Capybara.register_driver(:better_cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    {
      browser_options: { 'disable-smooth-scrolling': true }.merge(remote_chrome ? { 'no-sandbox' => nil } : {}),
      inspector: !remote_chrome,
      process_timeout: 20,
      window_size: [1200, 800],
    }.merge(remote_options)
  )
end

Capybara.default_driver = Capybara.javascript_driver = :better_cuprite

# Add shortcuts for cuprite-specific debugging helpers
module CupriteHelpers
  def pause
    page.driver.pause
  end

  def debug(binding = nil)
    $stdout.puts '🔎 Open Chrome inspector at http://localhost:3333/debugger?token=CHROMIUMTESTTOKEN'

    if binding.respond_to?(:pry)
      Pry.start(binding)
    elsif binding.respond_to?(:irb)
      binding.irb
    else
      pause
    end
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :system
  config.include CupriteHelpers, type: :feature
end
