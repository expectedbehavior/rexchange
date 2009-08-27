Gem::Specification.new do |s|
  s.name = %q{rexchange}
  s.version = "0.4.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.authors = ["Sam Smoot", "Scott Bauer". "Daniel Kwiecinski"]
  s.autorequire = %q{rexchange}
  s.date = %q{2009-08-27}
  s.description = %q{Connect, browse, and iterate through folders and messages on an Exchange Server}
  s.email = %q{ssmoot@gmail.com; bauer.mail@gmail.com; daniel@lambder.com}
  s.extra_rdoc_files = ["README", "CHANGELOG", "RAKEFILE", "MIT-LICENSE"]
  s.files = ["README", "CHANGELOG", "RAKEFILE", "MIT-LICENSE", "lib/r_exchange.rb", "lib/rexchange/appointment.rb", "lib/rexchange/contact.rb", "lib/rexchange/credentials.rb", "lib/rexchange/dav_get_request.rb", "lib/rexchange/dav_move_request.rb", "lib/rexchange/dav_search_request.rb", "lib/rexchange/exchange_request.rb", "lib/rexchange/folder.rb", "lib/rexchange/generic_item.rb", "lib/rexchange/message.rb", "lib/rexchange/note.rb", "lib/rexchange/session.rb", "lib/rexchange/task.rb", "lib/rexchange.rb", "test/functional.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://substantiality.net}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README"]
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = %q{rexchange}
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{A simple wrapper around Microsoft Exchange Server's WebDAV API (that works with Exchange 2007 using basic authentication and the form-based one. }
end
