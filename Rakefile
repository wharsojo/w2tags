# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'w2tags'

task :default => 'spec:run'

PROJ.name = 'w2tags'
PROJ.authors = 'widi harsojo'
PROJ.email = 'wharsojo@gmail.com'
PROJ.url = 'http://w2tags.rubyforge.org'
PROJ.rubyforge.name = 'w2tags'

PROJ.rdoc.opts << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
PROJ.rdoc.opts << '--charset' << 'utf-8' << '--all'

PROJ.spec.opts << '--color'

# EOF
