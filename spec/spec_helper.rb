# frozen_string_literal: true

require "bundler/setup"
require "dotenv/load"
require "esse/hooks"
require "esse/rspec"

require "support/config_helpers"
require "support/webmock"
require "pry"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include ConfigHelpers
end
