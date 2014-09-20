class CalculateScores
  def initialize(data_stream, analyzer = Sentimental)
    @stream    = data_stream
    @analyzer  = analyzer.new
  end

  def result # Calculate sentiment score
    @sentiment = @stream.inject(0) {|total, item| @analyzer.get_score(item.text) + total }
    @sentiment /= @stream.length
    sprintf("%0.02f", @sentiment * 10)
  end
end

