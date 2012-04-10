module Databasedotcom
  module Sobject
    
    # Generate customized SOQL queries. There are five different components that may be customized. These
    # are then combined to create the actual SOQL string:
    #
    #   "SELECT <selects> FROM <from> [WHERE <where>] [ORDER BY <order_by>] [LIMIT <limit>]"
    #
    # Each component is set via a chainable function. The SELECTS and FROM components are required.
    # (the name SELECTS was chosen to avoid conflict with the Enumerable #select method). The
    # five setter functions are defined in the COMPONENTS array.
    #
    #   q = Query.new
    #   q.select('field1, field2').from('Accounts').where('value > 5.0').order_by('name asc').limit(10)
    #   q.to_s  #=> 'SELECT field1, field2 FROM Accounts WHERE value > 5.0 ORDER BY name asc LIMIT 10'
    class Query
      
      COMPONENTS = %w(selects from where limit order_by)
      attr_reader :attrs
      
      def initialize(attrs = {})
        @attrs = {}
        COMPONENTS.each{|c| @attrs[c] = attrs[c]}
      end
      
      # Create chainable setters for the sql query components.
      COMPONENTS.each do |param|
        define_method("#{param}") do |value|
          @attrs[param] = value
          self
        end
      end
      
      # Create the SOQL statement.
      def to_s
        verify_components
        sql = "SELECT #{@attrs['selects']} FROM #{@attrs['from']}"
        sql += " WHERE #{@attrs['where']}" if @attrs['where']
        sql += " ORDER BY #{@attrs['order_by']}" if @attrs['order_by']
        sql += " LIMIT #{@attrs['limit']}" if @attrs['limit']
        sql
      end
      
      private
      
      def verify_components
        raise(InvalidQueryError, 'No SELECTS value was found') if @attrs['selects'].nil?
        raise(InvalidQueryError, 'No FROM value was found') if @attrs['from'].nil?
      end
      
    end
    
    class InvalidQueryError < StandardError; end

  end
end
