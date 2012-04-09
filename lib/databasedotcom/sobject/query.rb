require 'databasedotcom/sobject/query_components'

module Databasedotcom
  module Sobject
    class Query < QueryComponents
      
      def initialize(sobject)
        @sobject = sobject
        super({'select' => @sobject.field_list, 'from' => @sobject.sobject_name})
      end
      
      def all
        client.query(self.to_s)
      end
      
      def first
        all.first
      end
      
      def last
        all.last
      end
      
      def client
        @sobject.client
      end
      
      private
      
      # WARNING: If you try to include Enumerable in this class, you will have to rename the
      # #select function in QueryComponents because Enumerable also includes a #select function.
      
    end
  end
end