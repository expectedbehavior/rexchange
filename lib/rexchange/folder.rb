require 'rexml/document'
require 'net/https'
require 'rexchange/dav_search_request'
require 'rexchange/message'
require 'rexchange/contact'
require 'rexchange/appointment'

module RExchange

  class Folder
    include REXML
    
    include Enumerable
    
    attr_reader :credentails, :name
    
    def initialize(credentials, parent, name, content_type)
      @credentials, @parent, @name = credentials, parent, name
      @content_type = content_type
    end
    
    alias :old_method_missing :method_missing
    
    # Used to access subfolders. If the subfolder does not
    # exist, then old_method_missing is called.
    def method_missing(sym, *args)
      if folders.has_key?(sym.to_s)
        folders[sym.to_s]
      else
        old_method_missing(sym, args)
      end
    end
    
    # Iterate through each RExchange::Message in this folder
    def each
      content_type::find(@credentials, to_s).each do |item|
        yield item
      end
    end
    
    def content_type
      RExchange::const_get(RExchange::CONTENT_TYPES[@content_type])
    end
    
    def search(conditions = {})
      content_type::find(@credentials, to_s, conditions)
    end
    
    # Join the strings passed in with '/'s between them
    def self.join(*args)
      args.collect { |f| f.to_s.ensure_ends_with('/') }.to_s.squeeze('/')
    end
    
    # Return an Array of subfolders for this folder
    def folders
      @folders ||= get_folders
    end
    
    # Return the absolute path to this folder (but not the full URI)
    def to_s
      Folder.join(@parent, @name)
    end
    
    private
    
    def get_folders
      request_body = <<DA_QUERY
    				<?xml version="1.0"?>
    				<D:searchrequest xmlns:D = "DAV:">
    					 <D:sql>
    					 SELECT "DAV:displayname", "DAV:contentclass"
    					 FROM SCOPE('shallow traversal of "#{to_s}"')
    					 WHERE "DAV:ishidden" = false
                           AND "DAV:isfolder" = true
    					 </D:sql>
    				</D:searchrequest>
DA_QUERY
      
      response = DavSearchRequest.execute(@credentials, :body => request_body)
      
      folders = {}
      
      # iterate through folders query and add each normalized name to the folders array.
      xpath_query = "//a:propstat[a:status/text() = 'HTTP/1.1 200 OK']/a:prop"
      Document.new(response.body).elements.each(xpath_query) do |m|
        
        # p "#{m.elements['a:displayname'].text} : #{m.elements['a:contentclass'].text}"
        # Mail folders like "inbox" are urn:content-classes:mailfolder types.
        # Contacts folders like "contacts" are urn:content-classes:contactfolder types.
        # I think this would be a better way to handle folder enumeration...
        displayname = m.elements['a:displayname'].text
        contentclass = m.elements['a:contentclass'].text
        
        folders[displayname.normalize] = Folder.new(@credentials, self, displayname, contentclass.split(':').last)
      end
      
      return folders
    end
  end
end
