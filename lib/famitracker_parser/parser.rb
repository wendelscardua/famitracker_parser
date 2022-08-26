# frozen_string_literal: true

require_relative "song"
require_relative "row_channel"

module FamitrackerParser
  # The Parser itself
  class Parser
    def initialize(source)
      @source = source
      @current_line = 0
    end

    def parse!
      song = Song.new
      song.song_information = SongInformation.new
      song.song_comments = []
      song.global_settings = GlobalSettings.new
      song.macros = []
      song.dpcm_samples = []
      song.instruments = []
      song.tracks = []
      song.extras = {}

      @source.lines.map(&:chomp).each.with_index do |line, line_number|
        @current_line = line_number + 1
        if (description = export_description(line))
          song.export_description = description
        elsif comment(line) || empty(line)
          next
        elsif (command, args = famitracker_command(line))
          case command
          # Song information
          when "AUTHOR"
            song.song_information
                .author = parse_arg(args, :string)
          when "COPYRIGHT"
            song.song_information
                .copyright = parse_arg(args, :string)
          when "TITLE"
            song.song_information
                .title = parse_arg(args, :string)
          # Song comment
          when "COMMENT"
            song.song_comments << parse_arg(args, :string)
          # Global settings
          when "MACHINE"
            song.global_settings
                .machine = parse_arg(args, :decimal)
          when "FRAMERATE"
            song.global_settings
                .framerate = parse_arg(args, :decimal)
          when "EXPANSION"
            song.global_settings
                .expansion = parse_arg(args, :decimal)
          when "VIBRATO"
            song.global_settings
                .vibrato = parse_arg(args, :decimal)
          when "SPLIT"
            song.global_settings
                .split = parse_arg(args, :decimal)
          when "N163CHANNELS"
            song.global_settings
                .n163_channels = parse_arg(args, :decimal)
          # Macros
          when "MACRO"
            song.macros << Macro.new.tap do |macro|
              parsed = parse_args(args,
                                  {
                                    type: :decimal,
                                    id: :decimal,
                                    loop_index: :decimal,
                                    release_index: :decimal,
                                    arpeggio_type: :decimal,
                                    separator1: ":",
                                    values: { array: :decimal }
                                  })
              macro.type = parsed[:type]
              macro.id = parsed[:id]
              macro.loop_index = parsed[:loop_index]
              macro.release_index = parsed[:release_index]
              macro.arpeggio_type = parsed[:arpeggio_type]
              macro.values = parsed[:values]
            end
          # DPCM samples
          when "DPCMDEF"
            song.dpcm_samples << DPCMSample.new.tap do |dpcm_sample|
              parsed = parse_args(args,
                                  {
                                    id: :decimal,
                                    size: :decimal,
                                    name: :string
                                  })
              dpcm_sample.id = parsed[:id]
              dpcm_sample.size = parsed[:size]
              dpcm_sample.name = parsed[:name]
              dpcm_sample.bytes = []
            end
          when "DPCM"
            parsed = parse_args(args,
                                {
                                  separator: ":",
                                  bytes: { array: :hexadecimal }
                                })
            song.dpcm_samples.last.bytes += parsed[:bytes]
          # Instruments
          when "INST2A03"
            parsed = parse_args(args,
                                {
                                  id: :decimal,
                                  volume_macro: :decimal,
                                  arpeggio_macro: :decimal,
                                  pitch_macro: :decimal,
                                  hi_pitch_macro: :decimal,
                                  duty_noise_macro: :decimal,
                                  name: :string
                                })
            song.instruments << Instrument2A03.new.tap do |instrument|
              instrument.id = parsed[:id]
              instrument.volume_macro = parsed[:volume_macro]
              instrument.arpeggio_macro = parsed[:arpeggio_macro]
              instrument.pitch_macro = parsed[:pitch_macro]
              instrument.hi_pitch_macro = parsed[:hi_pitch_macro]
              instrument.duty_noise_macro = parsed[:duty_noise_macro]
              instrument.name = parsed[:name]
              instrument.dpcm_keys = []
            end
          when "KEYDPCM"
            parsed = parse_args(args,
                                {
                                  instrument_id: :decimal,
                                  octave: :decimal,
                                  note: :decimal,
                                  dpcm_sample_id: :decimal,
                                  pitch: :decimal,
                                  loop: :decimal,
                                  loop_point: :decimal,
                                  delta_counter: :decimal
                                })
            song.instruments.last.dpcm_keys << DPCMKey.new.tap do |dpcm_key|
              dpcm_key.octave = parsed[:octave]
              dpcm_key.note = parsed[:note]
              dpcm_key.dpcm_sample_id = parsed[:dpcm_sample_id]
              dpcm_key.pitch = parsed[:pitch]
              dpcm_key.loop = parsed[:loop]
              dpcm_key.loop_point = parsed[:loop_point]
              dpcm_key.delta_counter = parsed[:delta_counter]
            end
          when "INSTVRC7"
            parsed = parse_args(args, {
                                  id: :decimal,
                                  patch: :decimal,
                                  r0: :hexadecimal,
                                  r1: :hexadecimal,
                                  r2: :hexadecimal,
                                  r3: :hexadecimal,
                                  r4: :hexadecimal,
                                  r5: :hexadecimal,
                                  r6: :hexadecimal,
                                  r7: :hexadecimal,
                                  name: :string
                                })
            song.instruments << InstrumentVRC7.new.tap do |instrument|
              instrument.id = parsed[:id]
              instrument.patch = parsed[:patch]
              instrument.patch_registers = %i[r0 r1 r2 r3 r4 r5 r6 r7].map { |r| parsed[r] }
              instrument.name = parsed[:name]
            end
          # Tracks
          when "TRACK"
            parsed = parse_args(args,
                                {
                                  rows: :decimal,
                                  speed: :decimal,
                                  tempo: :decimal,
                                  name: :string
                                })
            song.tracks << Track.new.tap do |track|
              track.rows = parsed[:rows]
              track.speed = parsed[:speed]
              track.tempo = parsed[:tempo]
              track.name = parsed[:name]
              track.pattern_order = []
              track.patterns = []
            end
          when "COLUMNS"
            # it's just a list of how many effects per column, no need to parse it
            next
          when "ORDER"
            parsed = parse_args(args, {
                                  frame: :hexadecimal,
                                  separator: ":",
                                  patterns: { array: :hexadecimal }
                                })
            song.tracks.last.pattern_order << parsed[:patterns]
          when "PATTERN"
            song.tracks.last.patterns << Pattern.new.tap do |pattern|
              pattern.id = parse_arg(args, :hexadecimal)
              pattern.rows = []
            end
          when "ROW"
            parsed = parse_args(args, {
                                  id: :hexadecimal,
                                  rest: :rest
                                })
            song.tracks.last.patterns.last.rows << Row.new.tap do |row|
              row.id = parsed[:id]
              row.channels = RowChannel.parse_all(parsed[:rest])
            end
          ### Dn-Famitracker
          # Grooves
          when "GROOVE"
            dn_famitracker_extras = (song.extras[:dn_famitracker] ||= {})
            (dn_famitracker_extras[:grooves] ||= []) << Groove.new.tap do |groove|
              parsed = parse_args(args, {
                                    id: :decimal,
                                    size: :decimal,
                                    separator: ":",
                                    groove: { array: :decimal }
                                  })
              groove.id = parsed[:id]
              groove.groove = parsed[:groove]
            end
          # Tracks using default groove
          when "USEGROOVE"
            dn_famitracker_extras = (song.extras[:dn_famitracker] ||= {})
            parsed = parse_args(args, {
                                  separator: ":",
                                  tracks: { array: :decimal }
                                })
            dn_famitracker_extras[:default_groove_tracks] = parsed[:tracks]
          else
            raise ParserError, "Unknown command '#{command}' at line #{@current_line}"
          end
        else
          raise ParserError, "Invalid text at line #{@current_line}"
        end
      end

      song
    end

    def self.parse_file!(path)
      content = File.open(path, "r:iso-8859-1:utf-8", &:read)
      Parser.new(content).parse!
    end

    private

    def empty(line)
      line == ""
    end

    def comment(line)
      line.start_with?("#")
    end

    def parse_arg(args, type)
      tokenizer = ArgsTokenizer.new(args.strip)
      tokenizer.read(type)
    end

    def parse_args(args, types)
      tokenizer = ArgsTokenizer.new(args.strip)

      output = {}

      types.each do |name, type|
        output[name] = tokenizer.read(type)
      end

      output
    end

    def famitracker_command(line)
      return unless (match = line.match(/\A(?<command>[A-Z0-9]+)\s+(?<args>.*)\z/))

      [match["command"], match["args"]]
    end

    def export_description(line)
      return unless (match = line.match(/\A# (?<program>.*) text export (?<version>.*)\z/))

      ExportDescription.new.tap do |export_description|
        export_description.program = match["program"]
        export_description.version = match["version"]
      end
    end
  end

  ParserError = Class.new(StandardError)
end
