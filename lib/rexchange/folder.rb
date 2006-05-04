require 'rexml/document'
require 'net/https'
require 'rexchange/dav_search_request'
require 'rexchange/message'
require 'rexchange/contact'

module RExchange

  class Folder
    include REXML
    
    include Enumerable
    
    attr_reader :credentails
    
    def initialize(credentials, parent, folder)
      @credentials, @parent, @folder = credentials, parent, folder
    end
    
    alias :old_method_missing :method_missing
    
    # Used to access subfolders. If the subfolder does not
    # exist, then old_method_missing is called.
    def method_missing(sym, *args)
      if folders.has_key?(sym.to_s)
        Folder.new(@credentials, self, folders[sym.to_s] )
      else
        old_method_missing(sym, args)
      end
    end
    
    # Iterate through each RExchange::Message in this folder
    def each
      if @folder =~ /^contacts$/i || @parent =~ /\/contacts\//i
        get_contacts
      else
        get_messages
      end.each do |item|
        yield item
      end  
    end
    
    # Retrieve an Array of messages from a specific folder
    # === Example
    #   RExchange::open(uri, :user => 'bob', :password => 'random') do |mailbox|
    #     mailbox.messages_in('inbox/archive').each do |message|
    #       p message.from
    #     end
    #   end
    def messages_in(folder)
      folder.split('/').inject(@credentials.uri.path) do |final_path, current_path|
        Folder.new(@credentials, final_path, current_path)
      end.get_messages
    end
    
    def get_messages
      RExchange::Message::find(@credentials, to_s)
    end
    
    def get_contacts
      RExchange::Contact::find(@credentials, to_s)
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
      Folder.join(@parent, @folder)
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
        folders[m.elements['a:displayname'].text.normalize] = m.elements['a:displayname'].text
      end
      
      return folders
    end
  end
end
