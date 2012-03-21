require 'rspec'
require 'spec_helper'
require 'databasedotcom'
require 'databasedotcom/whitelist'

describe Databasedotcom::Whitelist do
  before do
    Databasedotcom::Blacklist.instance_variable_set(:@blacklist, {'classes' => [], 'fields' => {}})
  end
  
  describe '#allow_field?(field)' do
    before do
      @fake_class_name = 'FakeClassName'
    end
    it 'should indicate if a field is allowed/included' do
      Databasedotcom::Whitelist.whitelist = {'fields' => {@fake_class_name => [:foox]}}
      Databasedotcom::Whitelist.allow_field?(@fake_class_name, :foo).should be_false
      
      Databasedotcom::Whitelist.whitelist = {'fields' => {@fake_class_name => [:foo]}}
      Databasedotcom::Whitelist.allow_field?(@fake_class_name, :foo).should be_true
    end
    it 'should be true if there is no whitelist' do
      Databasedotcom::Whitelist.whitelist = nil
      Databasedotcom::Whitelist.allow_field?(@fake_class_name, :foo).should be_true
    end
    it 'should be true if the whitelist is blank' do
      Databasedotcom::Whitelist.whitelist = {'fields' => {@fake_class_name => []}}
      Databasedotcom::Whitelist.allow_field?(@fake_class_name, :foo).should be_true
    end
  end
  
  describe '#filter_sobjects(sobjects)' do
    it 'should only include whitelisted sobjects' do
      Databasedotcom::Whitelist.whitelist = {'classes' => [:a, :c]}
      Databasedotcom::Whitelist.filter_sobjects([:a, :b, :c, :d]).should == [:a, :c]
    end
    it 'should include all sobjects if there is no whitelist' do
      Databasedotcom::Whitelist.whitelist = nil
      Databasedotcom::Whitelist.filter_sobjects([:a, :b, :c, :d]).should == [:a, :b, :c, :d]
    end
  end

  describe '#filter_description!' do
    describe 'with a FIELDS keypair' do
      before do
        @fake_class_name = 'FakeClassName'
        @description_hash = {:a => 1, :b => 2, 'fields' => [{'name'=>'one'}, {'name'=>'two'}, {'name'=>'three'}]}
        Databasedotcom::Whitelist.stub(:allow_field?).with(@fake_class_name, 'one'){false}
        Databasedotcom::Whitelist.stub(:allow_field?).with(@fake_class_name, 'two') {true}
        Databasedotcom::Whitelist.stub(:allow_field?).with(@fake_class_name, 'three') {false}
      end
      it 'should only include allowed fields' do
        Databasedotcom::Whitelist.filter_description!(@description_hash, @fake_class_name)
        @description_hash['fields'].include?({'name'=>'one'}).should be_false
        @description_hash['fields'].include?({'name'=>'three'}).should be_false
      end
    end
    it 'should not change other keypairs' do
      description_hash = {:a => 1, :b => 2}
      description_hash_clone = description_hash.clone
      Databasedotcom::Whitelist.filter_description!(description_hash, @fake_class_name)
      description_hash_clone.should == description_hash
    end
  end

end

describe Databasedotcom::Client do
  before do
    @client = Databasedotcom::Client.new
  end
  describe '#describe_whitelist_sobjects_with_filter' do
    it 'should filter SObjects descriptions using the whitelist' do
      @client.should_receive(:describe_whitelist_sobjects_without_filter) { [{'description'=>1, 'name'=>2}] }
      Databasedotcom::Whitelist.should_receive(:filter_description!).with(1,2)
      @client.describe_sobjects
    end
    it 'should return the filtered sobjects' do
      sobjects = [ {'description'=>1, 'name'=>2} ]
      @client.should_receive(:describe_whitelist_sobjects_without_filter) { sobjects }
      Databasedotcom::Whitelist.stub(:filter_description!)
      @client.describe_sobjects.should == sobjects
    end
  end
  
  it 'should filter an SObject description fields using the whitelist' do
    description = mock()
    class_name = 'fake_class_name'
    @client.should_receive(:describe_whitelist_sobject_without_filter).with(class_name) { description }
    Databasedotcom::Whitelist.should_receive(:filter_description!).with(description, class_name)
    @client.describe_sobject(class_name).should == description
  end
  
  it 'should filter #list_sobjects using the whitelist' do
    sobjects = [1,2,3]
    filtered_sobjects = [1,2,3]
    @client.should_receive(:list_whitelist_sobjects_without_filter) { sobjects }
    Databasedotcom::Whitelist.should_receive(:filter_sobjects).once { filtered_sobjects } #.with(:list_sobjects_without_filter)
    @client.list_sobjects.should == filtered_sobjects
  end

end
