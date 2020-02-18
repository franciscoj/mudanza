require "mudanza/version"
require "roo"
require "colorize"

module Mudanza
  class Error < StandardError; end

  class CLI
    def run
      cajas =File.new.cajas
      search = Search.new(cajas)

      puts "MUDANZA!".colorize(:yellow)

      loop do
        puts "Escribe termino de busqueda:"
        print "> "
        term = gets.chomp

        result = search.run(term)
        result.print

        puts "\n" * 3

      rescue SignalException
        puts "\nAdios!".colorize(:red)
        exit
      end
    end
  end

  class File
    def cajas
      xlsx = Roo::Excelx.new(ENV["MUDANZA_FILE"])
      number = 0

      xlsx.map do |row|
        things = row.compact.map(&:downcase)
        number += 1

        Caja.new(number, things)
      end
    end
  end

  class Search
    def initialize(cajas)
      @cajas = cajas
    end

    def run(term)
      SearchResult.new(
        @cajas.find_all { |caja| caja.has?(term) },
        term
      )
    end
  end

  class SearchResult
    def initialize(cajas, term)
      @cajas = cajas
      @term = term
    end

    def print
      if empty?
        puts "Sin resultados".colorize(color: :black, background: :red)
      else
        decorate.map { |text| puts text }
      end
    end

    private

    def empty?
      @cajas.empty?
    end

    def decorate
      @cajas.map do |caja|
        content = caja.content.gsub(@term, @term.colorize(color: :black, background: :green))

        "Caja ##{caja.number}: #{content}"
      end
    end
  end

  class Caja
    include Enumerable

    attr_reader :number

    def initialize(number, things)
      @number = number
      @things = things
    end

    def each(&block)
      @things.each(&block)
    end

    def has?(str)
      any? { |thing| thing.include?(str) }
    end

    def content
      @things.join(", ")
    end
  end
end
