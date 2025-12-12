Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_storage.service = :local if defined?(ActiveStorage)
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.log_level = :debug
  config.log_tags = [:request_id]

  # Bullet for N+1 detection (commented out - gem not yet compatible with Rails 8)
  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.alert = false
  #   Bullet.bullet_logger = true
  #   Bullet.console = true
  #   Bullet.rails_logger = true
  #   Bullet.add_footer = false
  # end
end
