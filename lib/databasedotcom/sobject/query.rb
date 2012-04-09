module Databasedotcom
  module Sobject
    class Query
      
      def initialize(sobject_name, field_list)
        @attrs = {'select' => field_list, 'from' => sobject_name}
      end
      
      # Accessors for the sql query components. Each returns self so they are chainable.
      %w(select from where limit order_by).each do |param|
        define_method("#{param}") { |value| @attrs[param] = value; self }
      end
      
      def to_s
        sql = "SELECT #{@attrs['select']} FROM #{@attrs['from']}"
        sql += " WHERE #{@attrs['where']}" if @attrs['where']
        sql += " ORDER BY Id #{@attrs['order_by']}" if @attrs['order_by']
        sql += " LIMIT #{@attrs['limit']}" if @attrs['limit']
        sql
      end
      
    end
  end
end
