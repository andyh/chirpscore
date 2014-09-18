$stdout.sync = true # don't buffer stdout
require 'dotenv'
Dotenv.load
# require 'compass'
require 'sinatra'
require 'data_mapper'
require 'twitter'
require 'sentimental'
require 'open-uri'
require 'find'

require_relative 'lib/chirpscore'
require_relative 'config'
# require 'sass'
# require 'haml'

set :root, File.dirname(__FILE__)

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
	@happiest = Score.happiest
	@unhappiest = Score.unhappiest
	erb :home
end

post '/' do
  username = params[:user].downcase
  username[0] = '' if username[0] == '@'
  redirect '/' if !exists?(username)

  score = Score.first(:user => username)
  if score == nil
    score = Score.new
    score.attributes = {
      user: username,
      score: calculate_score(tweets(username)),
      created_at: Time.now,
      updated_at: Time.now,
    }
    score.save
  else
    score.score = sprintf("%0.02f", (score.score.to_f + calculate_score(tweets(username)).to_f) / 2)
    score.updated_at = Time.now
    score.save
  end
  redirect "/user/#{score.user}"
end

# User page

get '/user/:name' do
  @user = Score.first(:user => params[:name])
  redirect "/" unless @user
  @mood = mood(@user.score)
  @title = @user.user
  @home_layout = false
  erb :user
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
	Find.find('public/profile_images') do |path|
		if path.include? name
			exists = true 
			path.slice!(0, 7)
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
	file_path = "public/profile_images/#{name}.#{extension}"

	File.open(file_path, 'w') do |output|
      open(image_url) do |input|
        output << input.read
      end
    end
    image(name)
end

# Determine if user exists
def exists?(user)
	$client.user?(user) ? true : false
end


# Calculate sentiment score
def calculate_score(tweet_array)
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
