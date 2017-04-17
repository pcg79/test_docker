module CZ
  class FileProxy

    def initialize(path)
      @path = path
    end

    def read
      File.read(@path)
    end

  end
end
