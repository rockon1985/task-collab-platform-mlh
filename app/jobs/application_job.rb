# Application Job base class with error handling
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # Log job performance
  around_perform do |_job, block|
    start_time = Time.current
    block.call
    duration = Time.current - start_time
    Rails.logger.info("Job #{self.class.name} completed in #{duration.round(2)}s")
  end
end
