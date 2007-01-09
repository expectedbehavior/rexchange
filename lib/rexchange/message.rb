require 'rexchange/generic_item'

module RExchange
  class Message < GenericItem
    
    set_folder_type 'mail'
    
    attribute_mappings :from => 'urn:schemas:httpmail:from',
      :to => 'urn:schemas:httpmail:to',
      :message_id => 'urn:schemas:mailheader:message-id',
      :subject => 'urn:schemas:httpmail:subject',
      :recieved_on => 'urn:schemas:httpmail:date',
      :importance => 'urn:schemas:httpmail:importance',
      :has_attachments? => 'urn:schemas:httpmail:hasattachment',
      :body => 'urn:schemas:httpmail:textdescription',
      :html => 'urn:schemas:httpmail:htmldescription'
    
    # Move this message to the specified folder.
    # The folder can be a string such as 'inbox/archive' or a RExchange::Folder.
    # === Example
    #   mailbox.inbox.each do |message|
    #     message.move_to mailbox.inbox.archive
    #   end
    def move_to(folder)
      source = URI.parse(self.href).path
      destination = if folder.is_a?(RExchange::Folder)
        folder.to_s.ensure_ends_with('/') + source.split('/').last
      else
        @session.uri.path.ensure_ends_with('/') + folder.to_s.ensure_ends_with('/') + source.split('/').last
      end

      # $log.debug "move_to: source => \"#{source}\", destination => \"#{destination}\""
      DavMoveRequest.execute(@session, source, destination)
    end
    
    
    def to_s
      "To: #{to}, From: #{from}, Subject: #{subject}"
    end
    
  end
end