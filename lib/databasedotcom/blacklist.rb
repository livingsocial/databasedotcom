module Databasedotcom
  
  # Sometimes you don't want all of the SObjects or SObject fields. One vexing situation is an
  # SObject that has a huge number of fields because a query on that object can exceed the
  # maximum number of characters allowed in the URL path (8192). This produces a 500 error that
  # is quite difficult to understand. The solution is to remove some of the fields from the
  # SObject so the query URL is less than the 8192 character limit.
  #
  # You can effectively hide entire SObjects or individual fields via the blacklist. Create a hash
  # with keys 'classes' and/or 'fields' and specify the classes (as an array) and fields (as a hash of 
  # class / fieldname array pairs) to be excluded. 
  #
  #    my_blacklist = {'classes' => ['Account', 'Case'], 'fields' => {'Opportunity' => ['name']}}
  #    Databasedotcom::Blacklist.blacklist = my_blacklist
  class Blacklist
    
    @blacklist = {'classes' => [], 'fields' => {}}
    
    # Specify blacklisted class and field names in a hash. The 'class' keypair should contain an array
    # of SObject names and the 'fields' keypair should contain a hash of class name & field array keypairs.
    #    my.blacklist = {'classes' => ['Account', 'Case'], 'fields' => {'Opportunity' => ['field1', 'field2']}}
    def self.blacklist=(blacklist_hash)
      @blacklist = blacklist_hash || {}
      @blacklist['fields'] ||= {}
      @blacklist['classes'] ||= []
    end
    
    # Remove blacklisted fields from the description provided by Salesforce. Once the
    # fields are removed, Databasedotcom will not know about them or use them.
    def self.filter_description!(description, class_name)
      if description && description['fields']
        description['blacklisted_fields'] = description['fields'].select{|f| !allow_field?(class_name, f['name'])}
        description['fields'] = description['fields'].select{|f| allow_field?(class_name, f['name'])}
      end
    end
    
    def self.allow_field?(class_name, field)
      !blacklisted_fields(class_name).include?(field)
    end
    
    def self.filter_sobjects(sobjects)
      sobjects - blacklisted_classes
    end
    
    private
    
    def self.blacklisted_classes
      @blacklist['classes']
    end
    
    def self.blacklisted_fields(class_name)
      @blacklist['fields'][class_name] || []
    end
    
  end
  
  # Wrap the DESCRIBE_SOBJECT and DESCRIBE_SOBJECTS methods with the blacklist filter so
  # we never know about classes and/or fields that are blacklisted.
  class Client
    def describe_blacklist_sobjects_with_filter
      describe_blacklist_sobjects_without_filter.collect do |sobject|
        Databasedotcom::Blacklist.filter_description!(sobject['description'], sobject['name'])
        sobject
      end
    end
    alias_method :describe_blacklist_sobjects_without_filter, :describe_sobjects
    alias_method :describe_sobjects, :describe_blacklist_sobjects_with_filter

    def describe_blacklist_sobject_with_filter(class_name)
      description = describe_blacklist_sobject_without_filter(class_name)
      Databasedotcom::Blacklist.filter_description!(description, class_name)
      description
    end
    alias_method :describe_blacklist_sobject_without_filter, :describe_sobject
    alias_method :describe_sobject, :describe_blacklist_sobject_with_filter

    def list_blacklist_sobjects_with_filter
      Databasedotcom::Blacklist.filter_sobjects(list_blacklist_sobjects_without_filter)
    end
    alias_method :list_blacklist_sobjects_without_filter, :list_sobjects
    alias_method :list_sobjects, :list_blacklist_sobjects_with_filter

  end
  
end