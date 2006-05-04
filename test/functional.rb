require 'test/unit'
require 'rexchange'

class FunctionalTests < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
  end
  
  # Ok, so it's not a real test, but I needed to get started,
  # and get rid of console scripts.
  def test_no_exceptions
    
    uri = "https://#{ENV['rexchange_test_server']}/exchange/#{ENV['rexchange_test_mailbox']}/"
    options = { :user => ENV['rexchange_test_user'], :password => ENV['rexchange_test_password'] }

    RExchange::open(uri, options) do |mailbox|
      mailbox.inbox.each do |message|
        puts message.body
      end
      
      mailbox.folders.each { |folder| puts folder }
    end
    
  end
end