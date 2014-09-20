class Mood
  WORD_MAP = {
    -5 => 'an angry',
    -4 => 'an ill-tempered',
    -3 => 'a negative',
    -2 => 'an unhappy',
    -1 => 'an irritated',
    1 => 'an indifferent',
    2 => 'a pleasant',
    3 => 'a cheerful',
    4 => 'a joyous',
    5 => 'a happy',
  }
  DEFAULT_WORD = -> () { [0,"an ecstatic"] }
  def initialize(score)
    @score = score
  end

  def display
    WORD_MAP.find(DEFAULT_WORD) {|level,_| @score <= level }.last
  end
end
