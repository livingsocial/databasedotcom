require 'rspec'
require 'spec_helper'
require 'databasedotcom'

COMPONENTS = %w(select from where limit order_by)

class TestSobject < Databasedotcom::Sobject::Sobject
  def self.field_list
    'field1, field2, field3'
  end
  def self.sobject_name
    'TestSobject'
  end
end

describe Databasedotcom::Sobject::QueryComponents do
  describe Databasedotcom::Sobject::QueryComponents do
    before do
      @query = Databasedotcom::Sobject::QueryComponents.new
    end

    it 'should add setter functions for each query component' do
      COMPONENTS.each do |c|
        random_string = rand.to_s
        @query.send(c, random_string)
        @query.attrs[c].should equal(random_string)
        @query.send(c, random_string) # Verify that we can overwrite
        @query.attrs[c].should equal(random_string)
      end
    end
    
    context '#to_s' do
      it 'should require a SELECT component value' do
        @query.from('test')
        lambda {@query.to_s}.should raise_error(Databasedotcom::Sobject::InvalidQueryError)
      end
      it 'should require a FROM component value' do
        @query.select('test')
        lambda {@query.to_s}.should raise_error(Databasedotcom::Sobject::InvalidQueryError)
      end
      context 'with SELECT and FROM values' do
        it 'should create an appropriate SQL string' do
          sql = @query.from('one').select('two').to_s.downcase
          sql.should include('select two')
          sql.should include('from one')
        end
        context 'with a WHERE value' do
          it 'should create an appropriate SQL string' do
            sql = @query.from('one').select('two').where('first').to_s.downcase
            sql.should include('where first')
          end
        end
        context 'with a ORDER_BY value' do
          it 'should create an appropriate SQL string' do
            sql = @query.from('one').select('two').order_by('some string').to_s.downcase
            sql.should include('order by some string')
          end
        end
        context 'with a LIMIT value' do
          it 'should create an appropriate SQL string' do
            sql = @query.from('one').select('two').limit('infinity').to_s.downcase
            sql.should include('limit infinity')
          end
        end
        context 'with WHERE/ORDER_BY/LIMIT values' do
          it 'should create an appropriate SQL string' do
            sql = @query.from('one').select('two').where('first').order_by('some string').limit('infinity').to_s.downcase
            sql.should include('where first')
            sql.should include('order by some string')
            sql.should include('limit infinity')
          end
        end
      end
    end
  end

end
