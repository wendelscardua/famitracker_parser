# frozen_string_literal: true

module FamitrackerParser
  class Song
    attr_accessor :export_description,
                  :song_information,
                  :song_comment,
                  :global_settings
  end

  class ExportDescription
    attr_accessor :program, :version
  end

  class SongInformation
    attr_accessor :title, :author, :copyright
  end

  class GlobalSettings
    attr_accessor :machine,
                  :framerate,
                  :expansion,
                  :vibrato,
                  :split,
                  :n163_channels

    def expansion_description
      case @expansion
      when 0 then "NES channels only"
      when 1 then "Konami VRC6"
      when 2 then "Konami VRC7"
      when 4 then "Nintendo FDS sound"
      when 8 then "Nintendo MMC5"
      when 16 then "Namco 163"
      end
    end

    def vibrato_description
      case @vibrato
      when 0 then "Old style (bend up)"
      when 1 then "New style (bend up & down)"
      end
    end
  end
end
