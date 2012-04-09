module Databasedotcom
  module Sobject
    # This is an attempt to add ActiveRecord AREL-style features to DBDC queries. A query is composed of five
    # components: select, from, where, order_by and limit. Each component has a setter function takes a string
    # value. These string values are then used to generate the SOQL string. Note that the functions are chainable:
    #
    #   q = Query.new
    #   q.select('field1, field2').from('Accounts').where('value > 5.0').order_by('name asc').limit(10).to_s
    #     => 'SELECT field1, field2 FROM Accounts WHERE value > 5.0 ORDER BY name asc LIMIT 10'
    #
    # Unlike AREL, the SOQL fragment is not automatically created when an interator is used - you must call
    # #to_s to generate the string.
    class Query
      
      COMPONENTS = %w(select from where limit order_by)
      attr_reader :attrs
      
      def initialize(attrs = {})
        @attrs = {}
        COMPONENTS.each{|c| @attrs[c] = attrs[c]}
      end
      
      # Accessors for the sql query components. Each returns self so they are chainable.
      COMPONENTS.each do |param|
        define_method("#{param}") { |value| @attrs[param] = value; self }
      end
      
      # Create the SOQL statement using the various components. The SELECT and FROM components are required.
      def to_s
        verify_components
        sql = "SELECT #{@attrs['select']} FROM #{@attrs['from']}"
        sql += " WHERE #{@attrs['where']}" if @attrs['where']
        sql += " ORDER BY #{@attrs['order_by']}" if @attrs['order_by']
        sql += " LIMIT #{@attrs['limit']}" if @attrs['limit']
        sql
      end
      
      private
      
      def verify_components
        raise(InvalidQueryError, 'No SELECT value was found') if @attrs['select'].nil?
        raise(InvalidQueryError, 'No FROM value was found') if @attrs['from'].nil?
      end
      
    end
    
    class InvalidQueryError < StandardError; end

  end
end
