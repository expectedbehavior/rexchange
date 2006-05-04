require 'net/https'

module RExchange
  
  # Exchange Server's WebDAV interface is non-standard, so
  # we create this simple wrapper to extend the 'net/http'
  # library and add the request methods we need.
  class ExchangeRequest < Net::HTTPRequest
    REQUEST_HAS_BODY = true
    RESPONSE_HAS_BODY = true
    
    def self.execute(credentials, options = {})
      http = Net::HTTP.new(credentials.uri.host, credentials.uri.port)
      http.set_debug_output(RExchange::DEBUG_STREAM) if RExchange::DEBUG_STREAM
      request_path = options[:path] || credentials.uri.path
      req = self.new(request_path)
      req.basic_auth credentials.user, credentials.password
      req.content_type = 'text/xml'
      req.add_field 'host', credentials.uri.host
      
      if options[:headers]
        options[:headers].each_pair do |k, v|
          req.add_field k, v
        end
      end
      
      req.body = options[:body] if REQUEST_HAS_BODY
      http.use_ssl = credentials.use_ssl?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      return http.request(req) if RESPONSE_HAS_BODY
      return true
    end
    
    private
    # You can not instantiate an ExchangeRequest externally.
    def initialize(*args)
      super
    end
  end
end