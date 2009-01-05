# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{w2tags}
  s.version = "0.8.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["widi harsojo"]
  s.date = %q{2009-01-04}
  s.default_executable = %q{w2tags}
  s.description = %q{w2tags is the way to tags, a short cut / macros. when it do it use some patern  define in files (HOT file) to produce tags from minimal code to become full fledge tags}
  s.email = %q{wharsojo@gmail.com}
  s.executables = ["w2tags"]
  s.extra_rdoc_files = ["ERB.HOT.txt", "FAQ.txt", "HAML.txt", "History.txt", "HOT.txt", "README.txt", "bin/w2tags"]
  s.files = ["COPYING", "ERB.HOT.txt", "FAQ.txt", "HAML.txt", "History.txt", "HOT.txt", "LICENSE", "Manifest.txt", "Rakefile", "README.txt", "bin/w2tags", "lib/w2tags.rb", "lib/w2tags/parser.rb", "lib/w2tags/merb_hook.rb", "lib/w2tags/rails_hook.rb", "lib/w2tags/sinatra_hook.rb", "hot/erb.hot", "hot/erb_form.hot", "hot/erb_head.hot", "hot/erb_jquery.hot", "hot/erb_merb.hot", "hot/erb_table.hot", "hot/htm.hot", "hot/jquery.hot", "hot/nvelocity.hot", "hot/vm2.hot", "hot/vm.hot", "hot/vm_crud.hot", "hot/vm_popup.hot", "hot/xul.hot", "spec/spec_helper.rb", "spec/w2tags_spec.rb", "tasks/ann.rake", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/manifest.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake"]
  s.has_rdoc = true
  s.homepage = %q{w2tags.rubyforge.org}
  s.rdoc_options = ["--line-numbers", "--inline-source", "-A cattr_accessor=object", "--charset", "utf-8", "--all", "--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{w2tags}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{w2tags is the way to tags, a short cut / macros}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
