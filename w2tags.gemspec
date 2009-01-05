Gem::Specification.new do |s|
  s.name     = "w2tags"
  s.version  = "0.8.5"
  s.date     = "2009-01-05"
  s.summary  = "Way to Tags a HAML like Parser"
  s.email    = "wharsojo@gmail.com"
  s.homepage = "http://github.com/wharsojo/w2tags"
  s.description = "w2tags is the way to tags, a short cut / macros. when it do it use some patern define in files (HOT file) to produce tags from minimal code to become full fledge tags"
  s.has_rdoc = true
  s.authors  = ["Widi Harsojo"]
  s.files    = ["COPYING",
		"ERB.hot.txt",
		"FAQ.txt",
		"HAML.txt",
		"History.txt",
		"HOT.txt",
		"LICENSE",
		"Manifest.txt",
		"Rakefile",
		"README.txt",
		"bin/w2tags",
		"lib/w2tags.rb",
		"lib/w2tags/parser.rb",
		"lib/w2tags/merb_hook.rb",
		"lib/w2tags/rails_hook.rb",
		"lib/w2tags/sinatra_hook.rb",
		"hot/erb.hot",
		"hot/erb_form.hot",
		"hot/erb_head.hot",
		"hot/erb_jquery.hot",
		"hot/erb_merb.hot",
		"hot/erb_table.hot",
		"hot/htm.hot",
		"hot/jquery.hot",
		"hot/nvelocity.hot",
		"hot/vm2.hot",
		"hot/vm.hot",
		"hot/vm_crud.hot",
		"hot/vm_popup.hot",
		"hot/xul.hot",
		"spec/spec_helper.rb",
		"spec/w2tags_spec.rb",
		"tasks/ann.rake",
		"tasks/bones.rake",
		"tasks/gem.rake",
		"tasks/git.rake",
		"tasks/manifest.rake",
		"tasks/notes.rake",
		"tasks/post_load.rake",
		"tasks/rdoc.rake",
		"tasks/rubyforge.rake",
		"tasks/setup.rb",
		"tasks/spec.rake",
		"tasks/svn.rake",
		"tasks/test.rake"]
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["History.txt",
		"HOT.txt",
		"FAQ.txt",
		"ERB.hot.txt",
		"HAML.txt",
		"Manifest.txt",
    "LICENSE"]
end
