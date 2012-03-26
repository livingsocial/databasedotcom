module Databasedotcom
  
  class MaxPathLengthError < StandardError
    def initialize(path=nil)
      message = "Path length exceeds the #{MAX_PATH_LENGTH} character limit"
      message = "Path length #{path.length} exceeds the #{MAX_PATH_LENGTH} character limit -> #{path}" if path
      super(message)
    end
  end
  
  class NoFieldsError < StandardError
    def initialize(class_name)
      message = "SObject '#{class_name}' has no fields in its description, probably because the blacklist and / or whitelist are configured incorrectly"
      super(message)
    end
  end
  
end