require 'rspec'
require 'spec_helper'
require 'databasedotcom'
require 'databasedotcom/blacklist'

describe Databasedotcom::Blacklist do
  
  describe '#allow_field?(field)' do
    it 'should indicate if a field is allowed/included' do
      fake_class_name = 'FakeClassName'
      Databasedotcom::Blacklist.blacklist = nil
      Databasedotcom::Blacklist.allow_field?(fake_class_name, :foo).should be_true
      
      Databasedotcom::Blacklist.blacklist = {'fields' => {fake_class_name => []}}
      Databasedotcom::Blacklist.allow_field?(fake_class_name, :foo).should be_true
      
      Databasedotcom::Blacklist.blacklist = {'fields' => {fake_class_name => [:foox]}}
      Databasedotcom::Blacklist.allow_field?(fake_class_name, :foo).should be_true
      
      Databasedotcom::Blacklist.blacklist = {'fields' => {fake_class_name => [:foo]}}
      Databasedotcom::Blacklist.allow_field?(fake_class_name, :foo).should_not be_true
    end
  end
  
  describe '#filter_sobjects(sobjects)' do
    it 'should remove blacklisted sobjects' do
      Databasedotcom::Blacklist.blacklist = {'classes' => [:a, :c]}
      Databasedotcom::Blacklist.filter_sobjects([:a, :b, :c, :d]).should == [:b, :d]
    end
  end

  describe '#filter_description!' do
    describe 'with a FIELDS keypair' do
      before do
        @fake_class_name = 'FakeClassName'
        @description_hash = {:a => 1, :b => 2, 'fields' => [{'name'=>'one'}, {'name'=>'two'}, {'name'=>'three'}]}
        Databasedotcom::Blacklist.stub(:allow_field?).with(@fake_class_name, 'one'){true}
        Databasedotcom::Blacklist.stub(:allow_field?).with(@fake_class_name, 'two') {false}
        Databasedotcom::Blacklist.stub(:allow_field?).with(@fake_class_name, 'three') {true}
      end
      it 'should only include allowed fields' do
        Databasedotcom::Blacklist.filter_description!(@description_hash, @fake_class_name)
        @description_hash['fields'].include?({'name'=>'one'}).should be_true
        @description_hash['fields'].include?({'name'=>'three'}).should be_true
      end
      it 'should add a BLACKLISTED_FIELDS keypair' do
        Databasedotcom::Blacklist.filter_description!(@description_hash, @fake_class_name)
        @description_hash['blacklisted_fields'].include?({'name'=>'two'}).should be_true
      end
    end
    it 'should not change other keypairs' do
      description_hash = {:a => 1, :b => 2}
      description_hash_clone = description_hash.clone
      Databasedotcom::Blacklist.filter_description!(description_hash, @fake_class_name)
      description_hash_clone.should == description_hash
    end
  end

end

describe Databasedotcom::Client do
  before do
    @client = Databasedotcom::Client.new
  end
  describe '#describe_sobjects_with_filter' do
    it 'should filter SObjects descriptions using the blacklist' do
      @client.should_receive(:describe_sobjects_without_filter) { [{'description'=>1, 'name'=>2}] }
      Databasedotcom::Blacklist.should_receive(:filter_description!).with(1,2)
      @client.describe_sobjects
    end
    it 'should return the sobjects' do
      sobjects = [
        {'description'=>1, 'name'=>2},
        {'description'=>3, 'name'=>4},
        {'description'=>5, 'name'=>6},
      ]
      @client.should_receive(:describe_sobjects_without_filter) { sobjects }
      Databasedotcom::Blacklist.stub(:filter_description!)
      @client.describe_sobjects.should == sobjects
    end
  end
  
  it 'should filter an SObject description fields using the blacklist' do
    description = mock()
    class_name = 'fake_class_name'
    @client.should_receive(:describe_sobject_without_filter).with(class_name) { description }
    Databasedotcom::Blacklist.should_receive(:filter_description!).with(description, class_name)
    @client.describe_sobject(class_name).should == description
  end
  
  it 'should filter #list_sobjects using the blacklist' do
    sobjects = [1,2,3]
    @client.should_receive(:list_sobjects_without_filter) { sobjects }
    Databasedotcom::Blacklist.should_receive(:filter_sobjects).once { sobjects } #.with(:list_sobjects_without_filter)
    @client.list_sobjects.should == sobjects
  end

end
