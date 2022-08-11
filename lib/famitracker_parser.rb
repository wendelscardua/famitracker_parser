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

    def self.parse_file!(path)
      content = File.open(path, "r:iso-8859-1:utf-8", &:read)
      Parser.new(content).parse!
    end
  end
end
