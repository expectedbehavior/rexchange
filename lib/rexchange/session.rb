require 'uri'
require 'rexchange/folder'
require 'rexchange/credentials'

module RExchange 

  class Session < Folder
    
    # Creates a Credentials instance to pass to subfolders
    # === Example
    #   RExchange::Session.new('https://mydomain.com/exchange/demo', 'mydomain\\bob', 'secret') do |mailbox|
    #     mailbox.test.each do |message|
    #       puts message.subject
    #     end
    #   end
    def initialize(uri, username = nil, password = nil)
    
      @credentials = Credentials.new(uri, username, password)
      @parent = @credentials.uri.path
      @folder = ''
      
      yield(self) if block_given?
    end
      
  end 

end
