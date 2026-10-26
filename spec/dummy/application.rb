require "rails/all"
require 'sqlite3'

module Dummy
  APP_ROOT = File.expand_path("..", __FILE__).freeze

  class Application < Rails::Application

    config.root = APP_ROOT
    config.secret_key_base = "SECRET_KEY_BASE"
    config.eager_load = false

    # We want controller errors to be raised so we can expect them in controller_spec.rb.
    # With :none Rails raises the exception instead of rendering an error page.
    config.action_dispatch.show_exceptions = :none

    config.paths["app/assets"] << "#{APP_ROOT}/app/assets"
    config.paths["app/controllers"] << "#{APP_ROOT}/app/controllers"
    config.paths["app/models"] << "#{APP_ROOT}/app/models"
    config.paths["app/views"] << "#{APP_ROOT}/app/views"
    config.paths["config/database"] = "#{APP_ROOT}/config/database.yml"
    config.paths["log"] = "#{APP_ROOT}/log/application.log"
    config.paths.add "config/routes.rb", with: "#{APP_ROOT}/config/routes.rb"

    def require_environment!
      initialize!
    end
  end

end

Dummy::Application.initialize!
