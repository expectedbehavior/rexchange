require 'rexchange/generic_item'

module RExchange
  class Message < GenericItem
    
    def to_s
      "To: #{to}, From: #{from}, Subject: #{subject}"
    end
    
    attribute_mappings 'has_attachments?' => 'hasattachment'
    
    # Returns the body of the message. This is either a httpmail:textdescription,
    # or a httpmail:htmldescription
    def body
      @attributes['textdescription'] || @attributes['htmldescription']
    end
    
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

      $log.debug "move_to: source => \"#{source}\", destination => \"#{destination}\""
      DavMoveRequest.execute(@session, source, destination)
    end
    
    def self.search(path, conditions)
      qbody = [
      <<-QBODY
        SELECT "DAV:href", "urn:schemas:httpmail:from", "urn:schemas:httpmail:to",
  			   "urn:schemas:mailheader:message-id", "urn:schemas:httpmail:subject",
  			   "urn:schemas:httpmail:date", "urn:schemas:httpmail:importance",
  			   "urn:schemas:httpmail:hasattachment", "urn:schemas:httpmail:textdescription",
  			   "urn:schemas:httpmail:htmldescription"
  			 FROM SCOPE('shallow traversal of "#{path}"')
  			 WHERE "DAV:ishidden" = false
  				 AND "DAV:isfolder" = false
  				 AND "DAV:contentclass" = 'urn:content-classes:message'
			QBODY
		  ]
		  
		  mappings = {
		    :from => 'urn:schemas:httpmail:from',
		    :subject => 'urn:schemas:httpmail:subject'
		  }
		  
		  mappings.each_pair do |key, field|
		    qbody << "\"#{field}\" LIKE '%#{conditions[key]}%'" if conditions.has_key?(key)
      end
			
			qbody.map { |part| part.strip }.join("\n\tAND ")
    end
    
    def self.query(path)
      <<-QBODY
					 SELECT "DAV:href", "urn:schemas:httpmail:from", "urn:schemas:httpmail:to",
					   "urn:schemas:mailheader:message-id", "urn:schemas:httpmail:subject",
					   "urn:schemas:httpmail:date", "urn:schemas:httpmail:importance",
					   "urn:schemas:httpmail:hasattachment", "urn:schemas:httpmail:textdescription",
					   "urn:schemas:httpmail:htmldescription"
					 FROM SCOPE('shallow traversal of "#{path}"')
					 WHERE "DAV:ishidden" = false
						 AND "DAV:isfolder" = false
						 AND "DAV:contentclass" = 'urn:content-classes:message'
      QBODY
    end
  end
end