require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_view/railtie" # Disabled to avoid Active Storage dependency
# require "action_cable/railtie"

Bundler.require(*Rails.groups)

module TaskCollabPlatform
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true

    # Rails 8.1 timezone behavior
    config.active_support.to_time_preserves_timezone = :zone

    # Middleware for API
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end

    # Active Job
    config.active_job.queue_adapter = :sidekiq

    # Timezone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # Logging
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new
    config.lograge.custom_options = lambda do |event|
      {
        time: event.time,
        user_id: event.payload[:user_id],
        ip: event.payload[:ip]
      }
    end

    # Autoload lib/
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')
  end
end
