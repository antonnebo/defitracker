# Configure Solid Queue to use the queue database in production
# In development/test, it uses the default database
Rails.application.config.to_prepare do
  if Rails.env.production?
    SolidQueue::Record.connects_to database: { writing: :queue, reading: :queue }
  end
end
