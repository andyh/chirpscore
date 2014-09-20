$stdout.sync = true # don't buffer stdout
require 'dotenv'
Dotenv.load
# require 'compass'
require 'sinatra'
require 'data_mapper'
require 'twitter'
require 'sentimental'
require 'open-uri'
require 'ostruct'

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
  user = User.new(params[:user])
  redirect '/' unless user.exists?
  redirect "/user/#{user.handle}"
end

# User page

get '/user/:name' do
  @user = User.new(params[:name])
  redirect '/' unless @user.exists?
  @title = @user.handle
  @home_layout = false
  erb :user
end

def image(handle)
  user = OpenStruct.new(handle: handle)
  Avatar.new(user).image
end
