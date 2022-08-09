# frozen_string_literal: true

module FamitrackerParser
  class Song
    attr_reader :export_description,
                :song_information

    def initialize(export_description:,
                   song_information:)
      @export_description = export_description
      @song_information = song_information
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
end
