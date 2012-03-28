require 'databasedotcom/blacklist'

module Databasedotcom
  
  # Sometimes you don't want all of the SObjects or SObject fields. One vexing situation is an
  # SObject that has a huge number of fields because a query on that object can exceed the
  # maximum number of characters allowed in the URL path (8192). This produces a 500 error that
  # is quite difficult to understand. The solution is to remove some of the fields from the
  # SObject so the query URL is less than the 8192 character limit.
  #
  # You can effectively hide entire SObjects or individual fields via the whitelist. Create a hash
  # with keys 'classes' and/or 'fields' and specify the classes (as an array) and fields (as a hash of 
  # class / fieldname array pairs) to be excluded. 
  #
  #    my_whitelist = {'classes' => ['Account', 'Case'], 'fields' => {'Opportunity' => ['name']}}
  #    Databasedotcom::Whitelist.whitelist = my_whitelist
  class Whitelist
    
    @whitelist = {'classes' => [], 'fields' => {}}
    
    # Specify whitelisted class and field names in a hash. The 'class' keypair should contain an array
    # of SObject names and the 'fields' keypair should contain a hash of class name & field array keypairs.
    #    my.whitelist = {'classes' => ['Account', 'Case'], 'fields' => {'Opportunity' => ['field1', 'field2']}}
    def self.whitelist=(whitelist_hash)
      if whitelist_hash
        if (whitelist_hash['fields'].nil? && whitelist_hash['classes'].nil?)
          warn 'WARNING: The whitelist hash must contain at least a "fields" or "classes" keypair.'
        elsif (whitelist_hash.keys - ['fields', 'classes']).present?
          warn 'WARNING: The whitelist hash only accepts keys "fields" and "classes", all other keys are ignored.'
        end
      end
      @whitelist = whitelist_hash || {}
      @whitelist['fields'] ||= {}
      @whitelist['classes'] ||= []
    end
    
    # Remove whitelisted fields from the description provided by Salesforce. Once the
    # fields are removed, Databasedotcom will not know about them or use them.
    def self.filter_description!(description, class_name)
      if description && description['fields']
        description['fields'] = description['fields'].select{|f| allow_field?(class_name, f['name'])}
        raise Databasedotcom::NoFieldsError.new(class_name) unless description['fields'].length > 0
      end
    end
    
    def self.allow_field?(class_name, field)
      allowed_fields = whitelisted_fields(class_name)
      allowed_fields.length == 0 || allowed_fields.include?(field)
    end
    
    def self.filter_sobjects(sobjects)
      whitelisted_classes.length > 0 ? whitelisted_classes : sobjects
    end
    
    private
    
    def self.whitelisted_classes
      @whitelist['classes'] || []
    end
    
    def self.whitelisted_fields(class_name)
      @whitelist['fields'][class_name] || []
    end
    
  end
  
  # Wrap the DESCRIBE_SOBJECT and DESCRIBE_SOBJECTS methods with the whitelist filter so
  # we never know about classes and/or fields that are whitelisted.
  class Client
    def describe_whitelist_sobjects_with_filter
      describe_whitelist_sobjects_without_filter.collect do |sobject|
        Databasedotcom::Whitelist.filter_description!(sobject['description'], sobject['name'])
        sobject
      end
    end
    alias_method :describe_whitelist_sobjects_without_filter, :describe_sobjects
    alias_method :describe_sobjects, :describe_whitelist_sobjects_with_filter

    def describe_whitelist_sobject_with_filter(class_name)
      description = describe_whitelist_sobject_without_filter(class_name)
      Databasedotcom::Whitelist.filter_description!(description, class_name)
      description
    end
    alias_method :describe_whitelist_sobject_without_filter, :describe_sobject
    alias_method :describe_sobject, :describe_whitelist_sobject_with_filter

    def list_whitelist_sobjects_with_filter
      Databasedotcom::Whitelist.filter_sobjects(list_whitelist_sobjects_without_filter)
    end
    alias_method :list_whitelist_sobjects_without_filter, :list_sobjects
    alias_method :list_sobjects, :list_whitelist_sobjects_with_filter

  end
  
end