class Score
	include DataMapper::Resource
	property :id, Serial
	property :user, Text, :required => true
	property :score, Float, :required => true
	property :created_at, DateTime
	property :updated_at, DateTime

  def self.happiest
    self.all(order: [ :score.desc ],limit: 10)
  end

  def self.unhappiest
    self.all(order: [ :score.asc ],limit: 10)
  end

  def self.find_or_create_for(user)
    find_score_for(user) || create_score_for(user)
  end

  def self.find_score_for(user)
    score = Score.first(user: user.handle) or return
    score.attributes = {
      score: CalculateScores.new(user.fetch_data).result,
      updated_at: Time.now,
    }
    score.save
    score
  end

  def self.create_score_for(user)
    score = Score.new
    score.attributes = {
      user: user.handle,
      score: CalculateScores.new(user.fetch_data).result,
      created_at: Time.now,
      updated_at: Time.now,
    }
    score.save
    score
  end
end

