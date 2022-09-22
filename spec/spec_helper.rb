require 'byebug'

require_relative 'dummy/application'
# Rails.logger = ActiveSupport::Logger.new("spec/log/dummy-app.log")
#
# module ActiveRecord
#   module TestFixtures
#     def before_setup
#     end
#
#     def after_teardown
#     end
#   end
# end

$: << File.join(File.dirname(__FILE__), "/../lib" )
require 'unpoly-rails'
require 'rspec/rails'
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = false

  config.expect_with :rspec do |c|
    c.syntax = [:expect]
  end

end
