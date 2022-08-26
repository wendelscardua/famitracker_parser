# frozen_string_literal: true

module FamitrackerParser
  class RowChannel
    NOTE_OCTAVE_REGEX = /(?:\.\.\.|---|===|[0-9ABCDEFG][-#][0-9#])/.freeze
    EFFECT_REGEX = /(\.\.\.|[0-9A-Z][0-9A-F][0-9A-F])/.freeze
    ROW_CHANNEL_REGEX = /:
                        \s(?<note_octave>#{NOTE_OCTAVE_REGEX})
                        \s(?<instrument>[.0-9A-F]{2})
                        \s(?<volume>[.0-9A-F])
                        \s(?<effects>#{EFFECT_REGEX}(?:\s#{EFFECT_REGEX})*)/x.freeze

    attr_reader :note_octave,
                :instrument,
                :volume,
                :effects

    def initialize(note_octave:, instrument:, volume:, effects:)
      @note_octave = note_octave
      @instrument = instrument
      @volume = volume
      @effects = effects
    end

    def self.from_hash(hash)
      (@memoized_row_channels ||= {})[hash] ||=
        RowChannel.new(
          note_octave: hash["note_octave"].then do |note_octave|
            case note_octave
            when "..." then nil
            when "---" then :halt
            when "===" then :release
            else note_octave
            end
          end,
          instrument: hash["instrument"].then do |instrument|
            if instrument == ".."
              nil
            else
              instrument.to_i(16)
            end
          end,
          volume: hash["volume"].then do |volume|
            if volume == "."
              nil
            else
              volume.to_i(16)
            end
          end,
          effects: hash["effects"].then do |effects|
            effects.scan(EFFECT_REGEX).map do |(effect_match)|
              if effect_match == "..."
                nil
              else
                Effect.new.tap do |effect|
                  effect.command = effect_match[0]
                  effect.argument = effect_match[1..]
                end
              end
            end
          end
        )
    end

    def self.parse_all(row_channel_string)
      row_channel_string.scan(ROW_CHANNEL_REGEX)
                        .map { |match| ROW_CHANNEL_REGEX.names.zip(match).to_h }
                        .map do |row_channel_data|
        RowChannel.from_hash(row_channel_data)
      end
    end
  end

  class Effect
    attr_accessor :command, :argument
  end
end
