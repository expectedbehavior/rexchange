require 'rexchange/generic_item'

module RExchange
  class Contact < GenericItem
    
    attribute_mappings :first_name => 'given_name',
      :middle_name => 'middlename',
      :last_name => 'sn',
      :created_at => 'creationdate',
      :address => 'mailingstreet',
      :city => 'mailingcity',
      :state => 'st',
      :zip_code => 'mailingpostalcode',
      :country => 'co',
      :phone => 'home_phone',
      :business_phone => 'telephone_number',
      :fax => 'facsimiletelephonenumber',      
      :email => 'email1',
      :website => 'businesshomepage',
      :company => 'o'
    
    def self.query(path)
      <<-QBODY
					 SELECT "urn:schemas:contacts:givenName", "urn:schemas:contacts:middlename",
					  "urn:schemas:contacts:sn", "urn:schemas:contacts:title",
					  "urn:schemas:contacts:mailingstreet", "urn:schemas:contacts:mailingcity",
					  "urn:schemas:contacts:st", "urn:schemas:contacts:mailingpostalcode",
					  "urn:schemas:contacts:co", "urn:schemas:contacts:homePhone",
					  "urn:schemas:contacts:telephoneNumber", "urn:schemas:contacts:facsimiletelephonenumber",
					  "urn:schemas:contacts:mobile", "urn:schemas:contacts:email1",
					  "urn:schemas:contacts:businesshomepage", "urn:schemas:contacts:o", "DAV:creationdate"
					 FROM SCOPE('shallow traversal of "#{path}"')
					 WHERE "DAV:ishidden" = false
						 AND "DAV:isfolder" = false
						 AND "DAV:contentclass" = 'urn:content-classes:person'
      QBODY
    end

  end
end