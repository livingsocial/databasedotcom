module Databasedotcom
  module Sobject
    class Query
      
      COMPONENTS = %w(select from where limit order_by)
      
      def initialize(attrs = {})
        @attrs = {}
        COMPONENTS.each{|c| @attrs[c] = attrs[c]}
      end
      
      # Accessors for the sql query components. Each returns self so they are chainable.
      COMPONENTS.each do |param|
        define_method("#{param}") { |value| @attrs[param] = value; self }
      end
      
      def to_s
        verify_components
        sql = "SELECT #{@attrs['select']} FROM #{@attrs['from']}"
        sql += " WHERE #{@attrs['where']}" if @attrs['where']
        sql += " ORDER BY Id #{@attrs['order_by']}" if @attrs['order_by']
        sql += " LIMIT #{@attrs['limit']}" if @attrs['limit']
        sql
      end
      
      private
      
      def verify_components
        raise(InvalidQueryError, 'No SELECT value was found') if @attrs['select'].nil?
        raise(InvalidQueryError, 'No FROM value was found') if @attrs['from'].nil?
      end
      
    end
    
    class InvalidQueryError < StandardError
    end

  end
end
