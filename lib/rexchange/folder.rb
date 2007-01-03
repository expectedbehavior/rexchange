require 'rexml/document'
require 'net/https'
require 'rexchange/dav_search_request'
require 'rexchange/message'
require 'rexchange/contact'
require 'rexchange/appointment'

module RExchange

  class FolderNotFoundError < StandardError
  end
  
  class Folder
    include REXML
    
    attr_reader :credentails, :name
    
    def initialize(credentials, parent, name, content_type)
      @credentials, @parent, @name, @content_type = credentials, parent, name, content_type
    end
    
    # Used to access subfolders.
    def method_missing(sym, *args)
      if folders.has_key?(sym.to_s)
        folders[sym.to_s]
      else
        raise FolderNotFoundError.new("#{sym} is not a subfolder of #{name}")
      end
    end
    
    include Enumerable
    
    # Iterate through each entry in this folder
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
      @folders ||= begin
        request_body = <<-eos
      		<?xml version="1.0"?>
  				<D:searchrequest xmlns:D = "DAV:">
  					 <D:sql>
  					 SELECT "DAV:displayname", "DAV:contentclass"
  					 FROM SCOPE('shallow traversal of "#{to_s}"')
  					 WHERE "DAV:ishidden" = false
                         AND "DAV:isfolder" = true
  					 </D:sql>
  				</D:searchrequest>
        eos

        response = DavSearchRequest.execute(@credentials, :body => request_body)

        folders = {}

        # iterate through folders query and add a new Folder
        # object for each, under a normalized name.
        xpath_query = "//a:propstat[a:status/text() = 'HTTP/1.1 200 OK']/a:prop"
        Document.new(response.body).elements.each(xpath_query) do |m|
          displayname = m.elements['a:displayname'].text
          contentclass = m.elements['a:contentclass'].text
          folders[displayname.normalize] = Folder.new(@credentials, self, displayname, contentclass.split(':').last)
        end

        folders
      end
    end
    
    # Return the absolute path to this folder (but not the full URI)
    def to_s
      Folder.join(@parent, @name)
    end
  end
end
