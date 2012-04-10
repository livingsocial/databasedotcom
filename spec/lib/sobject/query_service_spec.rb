require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Sobject::QueryService do

  it 'should call Query #initialize' do
    sobject = mock()
    sobject.stub(:field_list) {''}
    sobject.stub(:sobject_name) {'fake-name'}
    Databasedotcom::Sobject::Query.should_receive(:new)
    query = Databasedotcom::Sobject::QueryService.new(sobject)
  end
  
  context 'with a client' do
    before do
      @sobject = mock()
      @sobject.stub(:field_list) {''}
      @sobject.stub(:sobject_name) {'fake-name'}
      @query = Databasedotcom::Sobject::QueryService.new(@sobject)
    end
    it 'should get all records' do
      result = 'blah'
      mock_client = mock()
      @query.should_receive(:to_s) { result }
      @query.should_receive(:send_query).with(result) {}
      @query.all
    end
    it 'should step through each record' do
      @query.should_receive(:all) { [1,2,3] }
      str = ''
      @query.each {|x| str += (x+1).to_s }
      str.should == '234'
    end
    it 'should get the last record' do
      @query.should_receive(:all) { [1,2,3] }
      @query.last.should == 3
    end
    it 'should print the SOQL statement' do
      @sobject.stub(:name) { 'my name is earl'}
      @query.should_receive(:puts)
      @query.print_soql
    end
    it 'should send the query string to the client' do
      result = 'abc'
      query_str = '1234'
      mock_client = mock()
      @query.should_receive(:client) { mock_client }
      mock_client.should_receive(:query).with(@query.to_s)
      @query.all
    end
  end

end
