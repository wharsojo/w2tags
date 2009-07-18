# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{w2tags}
  s.version = "0.9.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["widi harsojo"]
  s.date = %q{2009-07-18}
  s.default_executable = %q{w2tags}
  s.description = %q{w2tags is the way to tags, a short cut / macros. when it do it use some patern define in files (HOT file) to produce tags from minimal code to become full fledge tags}
  s.email = %q{wharsojo@gmail.com}
  s.executables = ["w2tags"]
  s.extra_rdoc_files = ["README.rdoc", "COPYING", "MIT-LICENSE", "doc/W2TAGS.rdoc", "doc/ERB.HOT.rdoc", "doc/FAQ.rdoc", "doc/HAML.rdoc", "doc/History.rdoc", "doc/HOT.rdoc", "bin/w2tags"]
  s.files = ["Manifest.txt", "README.rdoc", "Rakefile", "VERSION", "LICENSE", "COPYING", "MIT-LICENSE", "doc/W2TAGS.rdoc", "doc/ERB.HOT.rdoc", "doc/FAQ.rdoc", "doc/HAML.rdoc", "doc/History.rdoc", "doc/HOT.rdoc", "bin/w2tags", "lib/tags2w.rb", "lib/w2tags.rb", "lib/w2tags/parser.rb", "lib/w2tags/merb_hook.rb", "lib/w2tags/rails_hook.rb", "lib/w2tags/sinatra_hook.rb", "lib/w2tags/block/plain_text.rb", "lib/w2tags/block/remark.rb", "lib/w2tags/block/sass.rb", "hot/erb.hot", "hot/erb_form.hot", "hot/erb_head.hot", "hot/erb_jquery.hot", "hot/erb_merb.hot", "hot/erb_table.hot", "hot/html.hot", "hot/jquery.hot", "hot/nvelocity.hot", "hot/vm2.hot", "hot/vm.hot", "hot/vm_crud.hot", "hot/vm_popup.hot", "hot/xul.hot", "hot/rails/scaffold.hot", "hot/rails/sc_zebra.hot", "spec/spec_helper.rb", "spec/w2tags_spec.rb", "tasks/ann.rake", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/manifest.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake", "example", "example/common.hot", "example/rails_basic.hot", "example/from_readme.erb", "example/from_readme.w2erb", "example/from_w2tags.erb", "example/from_w2tags.w2erb", "test", "test/parser_test.rb", "test/w2tags_form.rb", "test/w2tags_hot.rb", "test/w2tags_hot_var.rb", "test/w2tags_no_parsing.rb", "test/w2tags_enlightning.rb", "test/w2tags_basic_usability.rb", "test/enlightning.hot", "test/feature.hot", "test/tricky.hot", "test/vars.hot", "plugins", "plugins/w2tags", "plugins/w2tags/generators", "plugins/w2tags/install.rb", "plugins/w2tags/README", "plugins/w2tags/generators/w2scaffold", "plugins/w2tags/generators/w2scaffold/templates", "plugins/w2tags/generators/w2scaffold/USAGE", "plugins/w2tags/generators/w2scaffold/w2scaffold_generator.rb", "plugins/w2tags/generators/w2scaffold/templates/controller.rb", "plugins/w2tags/generators/w2scaffold/templates/functional_test.rb", "plugins/w2tags/generators/w2scaffold/templates/helper.rb", "plugins/w2tags/generators/w2scaffold/templates/helper_test.rb", "plugins/w2tags/generators/w2scaffold/templates/layout.html.erb", "plugins/w2tags/generators/w2scaffold/templates/style.css", "plugins/w2tags/generators/w2scaffold/templates/view_edit.html.erb", "plugins/w2tags/generators/w2scaffold/templates/view_edit.html.w2erb", "plugins/w2tags/generators/w2scaffold/templates/view_index.html.erb", "plugins/w2tags/generators/w2scaffold/templates/view_index.html.w2erb", "plugins/w2tags/generators/w2scaffold/templates/view_new.html.erb", "plugins/w2tags/generators/w2scaffold/templates/view_new.html.w2erb", "plugins/w2tags/generators/w2scaffold/templates/view_show.html.erb", "plugins/w2tags/generators/w2scaffold/templates/view_show.html.w2erb"]
  s.has_rdoc = true
  s.homepage = %q{w2tags.rubyforge.org}
  s.rdoc_options = ["--line-numbers", "--inline-source", "-A cattr_accessor=object", "--charset", "utf-8", "--all", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{w2tags}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Its Way to Tags}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end
 
