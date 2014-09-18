DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV["DATABASE_URL"])
DataMapper.finalize.auto_upgrade!

# Sentiment Analysis -----------------------------------------------------------

Sentimental.load_defaults
