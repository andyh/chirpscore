class Score
	include DataMapper::Resource
	property :id, Serial
	property :user, Text, :required => true
	property :score, Float, :required => true
	property :created_at, DateTime
	property :updated_at, DateTime

  def self.happiest
    self.all(:order => [ :score.desc ],:limit => 10)
  end

  def self.unhappiest
    self.all(:order => [ :score.asc ],:limit => 10)
  end
end

