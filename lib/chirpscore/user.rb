require "forwardable"

class User
  extend Forwardable
  attr_reader :handle, :score

  def initialize(username)
    @handle = String(username).delete("@").downcase
    @chirper = Chirper.new(handle)
    @score = fetch_score if self.exists?
    self
  end

  def_delegators :@chirper, :exists?, :fetch_data
  def_delegators :@score, :score

  def mood
    Mood.new(self.score).display
  end

  private
  def fetch_score
    Score.find_or_create_for(self)
  end
end
