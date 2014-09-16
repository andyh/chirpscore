# require 'compass'
require 'sinatra'
require 'data_mapper'
require 'twitter'
require 'sentimental'
require 'open-uri'
require 'find'
# require 'sass'
# require 'haml'

set :root, File.dirname(__FILE__)
set :public, 'public'

# Configure SASS

# configure do
#   set :haml, {:format => :html5}
#   set :scss, {:style => :compact, :debug_info => false}
#   Compass.add_project_configuration(File.join(settings.root, 'config', 'compass.rb'))
# end

# get '/stylesheets/:name.css' do
#   content_type 'text/css', :charset => 'utf-8'
#   scss :"stylesheets/#{params[:name]}", Compass.sass_engine_options
# end

# get '/stylesheets' do
#   scss :style
# end

# Routes -----------------------------------------------------------------------

# Homepage

get '/' do
	@title = ''
	@home_layout = true
	@happiest = happiest
	@unhappiest = unhappiest
	erb :home
end

post '/' do
	username = params[:user].downcase
	username[0] = '' if username[0] == '@'
	if !exists?(username)
		redirect '/'
	else
		s = Score.first(:user => username)
		if s == nil
			s = Score.new
			s.user = username
			s.score = score(tweets(username))
			s.created_at = Time.now
			s.updated_at = Time.now
			s.save
		else
			s.score = sprintf("%0.02f", (s.score.to_f + score(tweets(username)).to_f) / 2)
			s.updated_at = Time.now
			s.save
		end
	end
	redirect "/#{s.user}"
end

# User page

get '/:name' do
	@user = Score.first(:user => params[:name])
	@mood = mood(@user.score)
	@title = @user.user
	@home_layout = false
	erb :user
end


# Database ---------------------------------------------------------------------

configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
    DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_BLUE_URL'])
end

class Score 
	include DataMapper::Resource
	property :id, Serial
	property :user, Text, :required => true
	property :score, Float, :required => true
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

#Configure Twitter -------------------------------------------------------------

$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "BWZjGf2K44l9oMxl2fbpmIcIZ"
  config.consumer_secret     = "o9xKwSzSbKwmpyaxDEQ5un58tQPEuzS30pKDmZfvZdkyu6lnXK"
  config.access_token        = "469774692-95NWeVs7YMWGZNxYCyhNqqucoml3AwN6rVPsPDGB"
  config.access_token_secret = "CJx9hZGLZeit4i8zY8GNp7vJWNA2NsTaLGEyTwcGkDwre"
end

# Fetch user Timeline tweets 
def tweets(user)
	begin
		$client.user_timeline(user.to_s)
	rescue
		redirect '/'
	end
end

# Check if user image exists, else download new one
def image(name)
	exists = false
	photo_path = ""
	Find.find('./app/public/profile_images/') do |path|
		if path.include? name
			exists = true 
			photo_path = path
		end
	end
	if exists
		return photo_path
	else
		download_image(name)
	end
end

# Download image
def download_image(name)
	image_url = $client.user(name).profile_image_url(:bigger).to_s

	extension = image_url.match(/(\w{3,4})$/)
	file_path = "profile_images/#{name}.#{extension}"

	File.new(file_path, 'w') do |output|
      open(image_url) do |input|
        output << input.read
      end
    end
    return file_path
end

# Determine if user exists
def exists?(user)
	$client.user?(user) ? true : false
end

# Sentiment Analysis -----------------------------------------------------------

Sentimental.load_defaults

# Calculate sentiment score
def score(tweet_array)
	@sentiment = 0
	tweet_array.each do |tweet|
		analyzer = Sentimental.new
		@sentiment += analyzer.get_score tweet.text
	end
	@sentiment /= tweet_array.length
	return sprintf("%0.02f", @sentiment * 10)
end

# Calculate mood based on score
def mood(score)
	mood = ''
	case
	when score.to_f < -5
		mood = 'an angry'
	when score.to_f < -4
		mood = 'an ill-tempered'
	when score.to_f < -3
		mood = 'a negative'
	when score.to_f < -2
		mood = 'an unhappy'
	when score.to_f < -1
		mood = 'an irritated'
	when score.to_f < 1
		mood = 'an indifferent' #i.e. -1 < mood < 1
	when score.to_f < 2
		mood = 'a pleasant'
	when score.to_f < 3
		mood = 'a cheerful'
	when score.to_f < 4
		mood = 'a joyous'
	when score.to_f < 5
		mood = 'a happy'
	else mood = 'an ecstatic'
	end
end

# Leaderboards -----------------------------------------------------------------

def happiest
	happiest = Score.all(:order => [ :score.desc ])
	happiest.slice!(0, 5)
end

def unhappiest
	unhappiest = Score.all(:order => [ :score.asc ])
	unhappiest.slice(0, 5)
end