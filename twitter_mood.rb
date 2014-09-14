require 'sinatra'
require 'data_mapper'
require 'twitter'
require 'sentimental'

# Routes -----------------------------------------------------------------------

# Homepage

get '/' do
	@title = ''
	erb :home
end

post '/' do
	s = Score.first(:user => params[:user])
	if s == nil
		s = Score.new
		s.user = params[:user]
		s.score = 7.6
		s.created_at = Time.now
		s.updated_at = Time.now
		s.save
	else
		s.score = 7.7
		s.updated_at = Time.now
		s.save
	end
	redirect "/#{s.user}"
end

# User page

get '/:name' do
	@user = Score.first(:user => params[:name])
	@mood = 'happy'
	@tweets = tweets("nbgoodall")
	#@score = Score.get params[:score]
	@title = @user.user
	erb :user
end


# SQLite Database --------------------------------------------------------------

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/twitter_mood.db")

class Score 
	include DataMapper::Resource
	property :id, Serial
	property :user, Text, :required => true
	property :score, Float, :required => true
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

#Configure Twitter

$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "BWZjGf2K44l9oMxl2fbpmIcIZ"
  config.consumer_secret     = "o9xKwSzSbKwmpyaxDEQ5un58tQPEuzS30pKDmZfvZdkyu6lnXK"
  config.access_token        = "469774692-95NWeVs7YMWGZNxYCyhNqqucoml3AwN6rVPsPDGB"
  config.access_token_secret = "CJx9hZGLZeit4i8zY8GNp7vJWNA2NsTaLGEyTwcGkDwre"
end

def tweets(user)
	$client.user_timeline(user)
end

#Sentiment Analysis

Sentimental.load_defaults

def score(tweet_array)
	
end