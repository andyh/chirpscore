require 'sinatra'
require 'data_mapper'
require 'twitter'

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
