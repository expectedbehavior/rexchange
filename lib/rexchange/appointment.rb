require 'rexchange/generic_item'

module RExchange
  class Appointment < GenericItem
    
    def self.query(path)
      <<-QBODY
	<?xml version="1.0"?>
	  <D:searchrequest xmlns:D = "DAV:">
	 <D:sql>
	 SELECT 
	   "urn:schemas:calendar:alldayevent",
           "urn:schemas:calendar:busystatus",
           "urn:schemas:calendar:contact",
           "urn:schemas:calendar:contacturl",
           "urn:schemas:calendar:created",
           "urn:schemas:calendar:descriptionurl",
           "urn:schemas:calendar:dtend",
           "urn:schemas:calendar:dtstamp",
           "urn:schemas:calendar:dtstart",
           "urn:schemas:calendar:duration",
           "urn:schemas:calendar:exdate",
           "urn:schemas:calendar:exrule",          
           "urn:schemas:httpmail:hasattachment", 
           "urn:schemas:httpmail:htmldescription", 
           "urn:schemas:calendar:instancetype", 
           "urn:schemas:calendar:lastmodified", 
           "urn:schemas:calendar:location", 
           "urn:schemas:calendar:locationurl", 
           "urn:schemas:calendar:meetingstatus", 
           "urn:schemas:httpmail:normalizedsubject", 
           "urn:schemas:httpmail:priority", 
           "urn:schemas:calendar:rdate", 
           "urn:schemas:calendar:recurrenceid", 
           "urn:schemas:calendar:recurrenceidrange", 
           "urn:schemas:calendar:reminderoffset", 
           "urn:schemas:calendar:replytime", 
           "urn:schemas:calendar:sequence", 
           "urn:schemas:mailheader:subject", 
           "urn:schemas:httpmail:subject", 
           "urn:schemas:httpmail:textdescription", 
           "urn:schemas:calendar:timezone", 
           "urn:schemas:calendar:timezoneid", 
           "urn:schemas:calendar:uid",
	"DAV:creationdate"
         FROM SCOPE('shallow traversal of "#{path}"')
	 WHERE "DAV:ishidden" = false
	 AND "DAV:isfolder" = false
	 AND "DAV:contentclass" = 'urn:content-classes:appointment'
          </D:sql>
	</D:searchrequest>
      QBODY
    end

  end
end  