# frozen_string_literal: true

module FamitrackerParser
  class ArgsTokenizer
    def initialize(string)
      @tokens = string.chars
    end

    def read(type)
      drop_spaces

      return nil if @tokens.empty?

      case type
      when :string then read_string
      when :decimal then read_decimal
      when :hexadecimal then read_hexadecimal
      when :rest then read_rest
      when String then read_literal(type)
      else
        if (type.is_a?(Hash) && (subtype = type[:array]))
          read_array(subtype)
        else
          raise FamitrackerParser::ParserError, "Invalid type: #{type.inspect}"
        end
      end
    end

    private

    def drop_spaces
      @tokens.shift while @tokens.first == " "
    end

    def read_literal(text)
      text_tokens = text.chars
      while !text_tokens.empty? && !@tokens.empty? &&
            text_tokens.first == @tokens.first
        text_tokens.shift
        @tokens.shift
      end

      raise FamitrackerParser::ParserError, "Literal doesn't match: #{text}" unless text_tokens.empty?
    end

    def read_string
      raise FamitrackerParser::ParserError, "Invalid string" if @tokens.shift != '"'

      string = ""
      string += @tokens.shift while @tokens.first && @tokens.first != '"'

      raise FamitrackerParser::ParserError, "Invalid string" if @tokens.shift != '"'

      string
    end

    def read_decimal
      decimal = ""

      while !@tokens.empty? && @tokens.first != " "
        digit = @tokens.shift
        raise ParserError, "Invalid decimal digit '#{digit}'" unless digit =~ /[-+\d]/

        decimal += digit
      end

      decimal.to_i
    end

    def read_hexadecimal
      hexadecimal = ""

      while !@tokens.empty? && @tokens.first != " "
        digit = @tokens.shift
        raise ParserError, "Invalid hexadecimal digit '#{digit}'" unless digit =~ /[-+\dA-F]/

        hexadecimal += digit
      end

      hexadecimal.to_i(16)
    end

    def read_rest
      rest = @tokens.join

      @tokens = []

      rest
    end

    def read_array(type)
      arr = []
      until (value = read(type)).nil?
        arr << value
      end
      arr
    end
  end
end
