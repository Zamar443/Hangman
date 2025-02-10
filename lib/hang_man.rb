require 'yaml'

class Hangman
  MAX_ATTEMPTS = 6
  WORDS_FILE = '1000-english.txt'

  def initialize
    @dictionary = File.readlines(WORDS_FILE).map(&:chomp).select { |word| word.length.between?(5, 12) }
    @secret_word = @dictionary.sample.downcase
    @attempts_left = MAX_ATTEMPTS
    @correct_letters = Array.new(@secret_word.length, '_')
    @incorrect_letters = []
  end

  def play
    loop do
      display_status
      puts "Enter a letter, 'save' to save, or 'exit' to quit:"
      input = gets.chomp.downcase

      case input
      when 'save'
        save_game
        puts "Game saved!"
      when 'exit'
        puts "Goodbye!"
        break
      else
        process_guess(input)
        if game_won?
          puts "Congratulations! You guessed the word: #{@secret_word}"
          break
        elsif @attempts_left.zero?
          puts "Game over! The word was: #{@secret_word}"
          break
        end
      end
    end
  end

  def display_status
    puts "\nWord: " + @correct_letters.join(' ')
    puts "Incorrect guesses: " + @incorrect_letters.join(', ')
    puts "Attempts left: #{@attempts_left}"
  end

  def process_guess(letter)
    if @secret_word.include?(letter) && !@correct_letters.include?(letter)
      @secret_word.chars.each_with_index { |char, i| @correct_letters[i] = char if char == letter }
    elsif !@incorrect_letters.include?(letter)
      @incorrect_letters << letter
      @attempts_left -= 1
    else
      puts "You've already guessed that letter!"
    end
  end

  def game_won?
    !@correct_letters.include?('_')
  end

  def save_game
    File.open('saved_game.yml', 'w') { |file| file.write(YAML.dump(self)) }
  end

  def self.load_game
  if File.exist?('saved_game.yml')
    begin
      saved_data = YAML.safe_load(File.read('saved_game.yml'), permitted_classes: [Hangman])
      return saved_data if saved_data.is_a?(Hangman)
    rescue StandardError => e
      puts "Error loading saved game: #{e.message}"
      puts "Starting a new game instead."
      new
    end
  else
    puts "No saved game found. Starting a new game."
    new
  end
end
end

puts "Welcome to Hangman! Type 'load' to resume or press Enter to start a new game."
input = gets.chomp.downcase

game = input == 'load' ? Hangman.load_game : Hangman.new
game.play
