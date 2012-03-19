module Databasedotcom
  
  class MaxPathLengthError < StandardError
    def initialize(path=nil)
      message = "Path length exceeds the #{MAX_PATH_LENGTH} character limit"
      message = "Path length #{path.length} exceeds the #{MAX_PATH_LENGTH} character limit -> #{path}" if path
      super(message)
    end
  end
    
end