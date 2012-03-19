require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::MaxPathLengthError do
  context "with a path string" do
    describe "#message" do
      it "returns the message with the path info" do
        path = 'abc123'
        @exception = Databasedotcom::MaxPathLengthError.new(path)
        @exception.message.should == "Path length #{path.length} exceeds the #{MAX_PATH_LENGTH} character limit -> #{path}"
      end
    end
  end
  
  context "without a path string" do
    describe "#message" do
      it "returns the message without path info" do
        @exception = Databasedotcom::MaxPathLengthError.new
        @exception.message.should == "Path length exceeds the #{MAX_PATH_LENGTH} character limit"
      end
    end
  end
end
