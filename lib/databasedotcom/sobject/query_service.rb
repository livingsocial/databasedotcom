require 'databasedotcom/sobject/query'

module Databasedotcom
  module Sobject
    
    # Generate and send a lazy-loaded SOQL query to Salesforce. The query is created from a Query
    # instance which allows us to use AREL-like chainable functions:
    #
    #  q = Query.new(Account)
    #  q.soql_query.where('VALUE > 10').limit(5).all #=> [0-5 Account results]
    class QueryService < Query

      include Enumerable
      
      def initialize(sobject)
        @sobject = sobject
        super({'selects' => @sobject.field_list, 'from' => @sobject.sobject_name})
      end
      
      # This is where the magic happens...
      def all
        send_query(self.to_s)
      end
      
      def each
        all.each{|x| yield x}
      end
      
      def last
        all.last
      end
      
      # Display the SOQL statement in the console, useful for inline debugging
      def print_soql
        puts "#{@sobject.name}: #{to_s}"
        self
      end
      
      private
      
      def send_query(query_str)
        client.query(query_str)
      end
      
      def client
        @sobject.client
      end
      
    end
  end
end