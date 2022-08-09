module FamitrackerParser
  class File
    attr_reader :description, :etc

    def initialize(description:,
                   etc:)
      @description = description
      @etc = etc
    end
  end

  class FileDescription
    attr_reader :program, :version

    def initialize(program:, version:)
      @program = program
      @version = version
    end
  end
end
