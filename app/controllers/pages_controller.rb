class PagesController < ApplicationController
  def game
    @grid = generate_grid(9)
    session[:grid] = @grid
    session[:score] ||= []
    session[:games] = 0 if session[:games].blank?
  end

  def score
    @attempt = params[:attempt]
    @end_time = Time.now
    @start_time = params[:start_time].to_time
    @grid = session[:grid]
    @timing = game_timer(@start_time, @end_time)
    @translation = translate_word(@attempt, @grid)
    @validation = attempt_validation(@attempt, @grid)
    @score = game_score(@timing, @attempt, @grid)
    session[:score] << @score
    @average_score = average_score
    @games = total_games
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { [*"A".."Z"].sample }
  end

  def attempt_validation_english(attempt)
    File.read('/usr/share/dict/words').split("\n").include?(attempt)
  end

  def attempt_validation_grid(attempt, grid)
    attempt_array = attempt.upcase.split("")
    attempt_array.all? do |char|
      attempt_array.count(char) <= grid.count(char)
    end
  end

  def attempt_validation(attempt, grid)
    if attempt_validation_grid(attempt, grid) && attempt_validation_english(attempt)
      "Well done"
    elsif attempt_validation_english(attempt) == false
      "It's not an english word, try again"
    elsif attempt_validation_grid(attempt, grid) == false
      "You used letters not provided in grid. Try again :)"
    end
  end

  def translate_word(attempt, grid)
    if attempt_validation_grid(attempt, grid) && attempt_validation_english(attempt)
      word = attempt
      key = "4d061f9d-f693-443c-9418-6d0c2c771a73"
      url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{key}&input=#{word}"
      attempt_translation = open(url).read
      translation = JSON.parse(attempt_translation)
      translation["outputs"][0]["output"].to_s
    end
  end

  def game_timer(start_time, end_time)
    time = end_time - start_time
    time.round / 1000
  end

  def game_score(timer, attempt, grid)
    if attempt_validation_grid(attempt, grid) && attempt_validation_english(attempt)
      attempt.size - timer * 1000
    elsif attempt_validation_english(attempt) == false
      0
    elsif attempt_validation_grid(attempt, grid) == false
      0
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    result = {}
    timer = game_timer(start_time, end_time)
    result[:message] = attempt_validation(attempt, grid)
    result[:translation] = translate_word(attempt, grid)
    result[:time] = game_timer(start_time, end_time)
    result[:score] = game_score(timer, attempt, grid)
    result
  end

  def average_score
    session[:score].inject{ |sum, el| sum + el } / session[:score].size
  end

  def total_games
    session[:games] += 1
  end
end
