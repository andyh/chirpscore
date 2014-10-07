class BirdcageError < StandardError; end
class Birdcage
  def initialize(user)
    @user   = user
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def fetch_data
		@client.user_timeline(@user)
  rescue Twitter::Error
    raise BirdcageError, "Couldn't access Twitter"
  end

  def exists?
    @client.user?(@user)
  end

  def user
    @client.user(@user)
  end
end
