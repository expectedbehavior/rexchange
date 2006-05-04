require 'uri'
require 'rexchange/folder'
require 'rexchange/credentials'

module RExchange 

  class Session < Folder
    
    # Creates a Credentials instance to pass to subfolders
    # === Example
    #   uri = 'https://mydomain.com/exchange/demo'
    #   options = { :user => 'test', :password => 'random' }
    # 
    #   RExchange::Session.new(uri, options) do |mailbox|
    #     mailbox.test.each do |message|
    #       puts message.subject
    #     end
    #   end
    def initialize(uri, options = {})
    
      @credentials = Credentials.new(uri, options)
      @parent = @credentials.uri.path
      @folder = ''
      
      yield(self) if block_given?
    end
      
  end 

end
