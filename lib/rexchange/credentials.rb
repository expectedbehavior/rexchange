require 'uri'

module RExchange

  # Credentials are passed around between Folders to emulate a stateful
  # connection with the RExchange::Session
  class Credentials
    attr_reader :user, :password, :uri

    # You must pass a uri, a username and a password
    def initialize(uri, username = nil, password = nil)
      @uri = URI.parse(uri)
      @use_ssl = (@uri.scheme.downcase == 'https')
      @user = @uri.userinfo ? @user.userinfo.split(':')[0] : username
      @password = @uri.userinfo ? @user.userinfo.split(':')[1] : password
      @port = @uri.port || @uri.default_port
            
      if block_given?
        yield self
      else
        return self
      end
    end
    
    def use_ssl?
      @use_ssl
    end
    
  end
  
end