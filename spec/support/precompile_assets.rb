# frozen_string_literal: true

# Precompile assets before running tests to avoid timeouts.
# Do not precompile if webpack-dev-server is running (NOTE: MUST be launched with RAILS_ENV=test)
RSpec.configure do |config|
  config.before(:suite) do
    unless ENV['CAPYBARA_APP_HOST'] # If tests DO NOT hit a remote rails server, precompile assets
      examples = RSpec.world.filtered_examples.values.flatten

      has_no_browser_tests = examples.none? { |example| %i[system feature].include?(example.metadata[:type]) }

      if has_no_browser_tests
        $stdout.puts "\n🚀️️  No system test selected. Skip assets compilation.\n"
      else
        $stdout.puts "\n🐢  Precompiling assets.\n"
        original_stdout = $stdout.clone

        start = Time.current
        begin
          $stdout.reopen(File.new('/dev/null', 'w'))

          require 'rake'
          Rails.application.load_tasks
          Rake::Task['assets:precompile'].invoke
        ensure
          $stdout.reopen(original_stdout)
          $stdout.puts "Finished in #{(Time.current - start).round(2)} seconds"
        end
      end
    end
  end
end
