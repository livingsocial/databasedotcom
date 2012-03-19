module Databasedotcom
  class Blacklist
    @blacklist = {'classes' => [], 'fields' => {}}
    
    # Specify blacklisted class and field names in a hash.
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
  # we never know about fields that are blacklisted.
  class Client
    def describe_sobjects_with_filter
      describe_sobjects_without_filter.collect do |sobject|
        Databasedotcom::Blacklist.filter_description!(sobject['description'], sobject['name'])
        sobject
      end
    end
    alias_method :describe_sobjects_without_filter, :describe_sobjects
    alias_method :describe_sobjects, :describe_sobjects_with_filter

    def describe_sobject_with_filter(class_name)
      description = describe_sobject_without_filter(class_name)
      Databasedotcom::Blacklist.filter_description!(description, class_name)
      description
    end
    alias_method :describe_sobject_without_filter, :describe_sobject
    alias_method :describe_sobject, :describe_sobject_with_filter

    def list_sobjects_with_filter
      Databasedotcom::Blacklist.filter_sobjects(list_sobjects_without_filter)
    end
    alias_method :list_sobjects_without_filter, :list_sobjects
    alias_method :list_sobjects, :list_sobjects_with_filter

  end
  
end