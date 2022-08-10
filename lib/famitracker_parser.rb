# frozen_string_literal: true

require_relative "famitracker_parser/version"

require "treetop"

# Main Famitracker parser module
module FamitrackerParser
  Treetop.load "lib/famitracker_text_grammar"

  class Parser
    def initialize(source)
      @source = source
      @grammar_parser = FamitrackerTextGrammarParser.new
    end

    def parse
      @grammar_parser.parse(@source)&.value
    end

    def parse!
      parse || raise(failure)
    end

    def failure
      @grammar_parser.failure_reason
    end
  end

  def self.playground
    content = File.open("spec/fixtures/2a03-example.txt", "r:iso-8859-1:utf-8", &:read)
    parser = Parser.new(content)
    result = parser.parse!
    require "pry"
    binding.pry
  end
end
