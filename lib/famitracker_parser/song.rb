# frozen_string_literal: true

module FamitrackerParser
  class Song
    attr_reader :export_description,
                :song_information,
                :song_comment,
                :global_settings

    def initialize(export_description:,
                   song_information:,
                   song_comment:,
                   global_settings:)
      @export_description = export_description
      @song_information = song_information
      @song_comment = song_comment
      @global_settings = global_settings
    end
  end

  class ExportDescription
    attr_reader :program, :version

    def initialize(program:, version:)
      @program = program
      @version = version
    end
  end

  class SongInformation
    attr_reader :title, :author, :copyright

    def initialize(title:, author:, copyright:)
      @title = title
      @author = author
      @copyright = copyright
    end
  end

  class SongComment
    attr_reader :comment

    def initialize(comment:)
      @comment = comment
    end
  end

  class GlobalSettings
    attr_reader :machine,
                :framerate,
                :expansion,
                :vibrato,
                :split

    def initialize(machine:,
                   framerate:,
                   expansion:,
                   vibrato:,
                   split:)
      @machine = machine
      @framerate = framerate
      @expansion = expansion
      @vibrato = vibrato
      @split = split
    end
  end
end
