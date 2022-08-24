# frozen_string_literal: true

module FamitrackerParser
  class Song
    attr_accessor :export_description,
                  :song_information,
                  :song_comment,
                  :global_settings,
                  :macros,
                  :dpcm_samples,
                  :instruments,
                  :tracks
  end

  class ExportDescription
    attr_accessor :program, :version
  end

  class SongInformation
    attr_accessor :title, :author, :copyright
  end

  class GlobalSettings
    EXPANSIONS = [
      [1, "Konami VRC6"],
      [2, "Konami VRC7"],
      [4, "Nintendo FDS sound"],
      [8, "Nintendo MMC5"],
      [16, "Namco 163"]
    ].freeze

    attr_accessor :machine,
                  :framerate,
                  :expansion,
                  :vibrato,
                  :split,
                  :n163_channels

    def expansion_description
      if @expansion == 0
        ["NES channels only"]
      else
        EXPANSIONS.reject { |(key, _value)| (@expansion & key) == 0 }
                  .map { |_key, value| value }
      end
    end

    def vibrato_description
      case @vibrato
      when 0 then "Old style (bend up)"
      when 1 then "New style (bend up & down)"
      end
    end
  end

  class Macro
    attr_accessor :type,
                  :id,
                  :loop_index,
                  :release_index,
                  :arpeggio_type,
                  :values

    def type_description
      case @type
      when 0 then "Volume"
      when 1 then "Arpeggio"
      when 2 then "Pitch"
      when 3 then "Hi-Pitch"
      when 4 then "Duty / Noise"
      end
    end

    def arpeggio_type_description
      return unless @type == 1

      case @arpeggio_type
      when 0 then "Absolute"
      when 1 then "Fixed"
      when 2 then "Relative"
      end
    end
  end

  class DPCMSample
    attr_accessor :id,
                  :size,
                  :name,
                  :bytes
  end

  class Instrument2A03
    attr_accessor :id,
                  :volume_macro,
                  :arpeggio_macro,
                  :pitch_macro,
                  :hi_pitch_macro,
                  :duty_noise_macro,
                  :name,
                  :dpcm_keys
  end

  class InstrumentVRC7
    attr_accessor :id,
                  :patch,
                  :patch_registers
  end

  class DPCMKey
    attr_accessor :octave,
                  :note,
                  :dpcm_sample_id,
                  :pitch,
                  :loop,
                  :d_counter
  end

  class Track
    attr_accessor :rows,
                  :speed,
                  :tempo,
                  :name,
                  :pattern_order,
                  :patterns
  end

  class Pattern
    attr_accessor :id,
                  :rows
  end

  class Row
    attr_accessor :id,
                  :channels
  end

  class RowChannel
    attr_accessor :note_octave,
                  :instrument,
                  :volume,
                  :effects
  end

  class Effect
    attr_accessor :command, :argument
  end
end
