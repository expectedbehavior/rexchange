require 'rexml/document'
require 'ostruct'
require 'rexchange/dav_move_request'
require 'time'

module RExchange
  class GenericItem
    include REXML
    include Enumerable

    attr_accessor :attributes

    # Used to access the attributes of the item as a hash.
    def [](key)
      return @attributes[key]
    end

    # Used to access the attributes of the item.
    def method_missing(sym, *args)
      return @attributes[sym.to_s] if @attributes.include?(sym.to_s)
    end

    def initialize(session, dav_property_node)
      @attributes = {}
      @session = session

      dav_property_node.elements.each do |element|
        if element.name.normalize =~ /date$/i
          @attributes[element.name.normalize] = Time::parse(element.text)
        else
          @attributes[element.name.normalize] = element.text
        end
      end

      return self 
    end

    def self.attribute_mappings(mappings)
      mappings.each_pair do |k,v|
        define_method k do
          @attributes[v]
        end
      end
    end

    def self.query(path)
      raise 'YOU MUST DEFINE THIS'
    end
    
    # Retrieve an Array of items (such as Contact, Message, etc)
    def self.find(credentials, path, conditions = nil)
      qbody = <<-QBODY
        <?xml version="1.0"?>
  			<D:searchrequest xmlns:D = "DAV:">
  				 <D:sql>
           #{conditions.nil? ? query(path) : search(path, conditions)}
           </D:sql>
        </D:searchrequest>
      QBODY
      
      response = DavSearchRequest.execute(credentials, :body => qbody)

      items = []
      xpath_query = "//a:propstat[a:status/text() = 'HTTP/1.1 200 OK']/a:prop"

      Document.new(response.body).elements.each(xpath_query) do |m|
        items << self.new(credentials, m)
      end

      return items
    end
  end
end