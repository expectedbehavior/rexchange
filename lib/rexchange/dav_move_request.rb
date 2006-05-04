require 'rexchange/exchange_request'

module RExchange
  # Used to move entities to different locations in the accessable mailbox.
  class DavMoveRequest < ExchangeRequest
    METHOD = 'MOVE'
    REQUEST_HAS_BODY = false
    RESPONSE_HAS_BODY = false
    
    def self.execute(credentials, source, destination)
      options = {
        :headers => {
        'Destination' => destination
        },
        :path => source
      }
      
      super credentials, options
    end
  end
  
end
