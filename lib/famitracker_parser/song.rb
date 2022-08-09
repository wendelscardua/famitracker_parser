# frozen_string_literal: true

module FamitrackerParser
  class Song
    attr_reader :export_description,
                :song_information,
                :song_comment

    def initialize(export_description:,
                   song_information:,
                   song_comment:)
      @export_description = export_description
      @song_information = song_information
      @song_comment = song_comment
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
end
