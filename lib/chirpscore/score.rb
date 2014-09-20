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
    Score.first(user: user.handle) || create_score_for(user)

    # TODO should be updating score
    # score.score = sprintf("%0.02f", (score.score.to_f + calculate_score(tweets_for(username)).to_f) / 2)
    # score.updated_at = Time.now
    # score.save
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

