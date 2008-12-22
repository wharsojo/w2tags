== W2TAGS
   by Widi Harsojo, http://wharsojo.wordpress.com

== DESCRIPTION:

w2tags is the way to tags, a short cut / macros. when it do it use some patern 
define in files (HOT file) to produce tags from minimal code to become full fledge tags 

== FEATURES

Before it release it use some patern, but I reliaze, today web development have 
some popular patern in view engine, so I change the patern. Now syntax mimics HAML 
to easy transisition, and proven to be useable and best.

Extended Syntax is the remain patern before I choose HAML like syntax, like 
"^ Next Tag will be use", redefinition "^" command using "~", define variable "&var=", 
define uniq variable "@var=", constanta variable"*var*" for attribute ID, CLASS, NAME. 
This Constanta will be ready every time it parse the W2TAGS (%) or parse the HOT(% / -).

HOT file is the powerfull features in w2tags, it contains some patern that you can
call it later using command "%" or "-", it contains one or more line of html/w2tags/hot
command, if you detect in you source that not DRY you can migrate the patern to hot
files and later you can call it

The rest of the command you can see it by reading source of w2tag::parser. 
So you can code less typing.

== PROBLEMS:

=== Demo files

Some of Demo not yet convert to new patern so please not to tray it, I'll do it 
if I have some time to do it. 

=== Auto closing for Code

Closing tags for HAML code like:

  - if <condition>

does not have automatically close so you must closing it your self with

  - end

for w2erb, the HOT have definition for autoclosing and the help from
method on parser "shortcut_exec(regex)", now it can auto intelligent 
closing

  -if index>100
    .bigger bigger than 100
  -elsif index>50
    .bigger bigger than 50 but less than 100
  -else
    .less less than 50

  .common
    Common Tag

work around to have a closing code, you can use feature to save some patern
in a hot file and use it in your code, example: "common.hot"

  >>_if
  - if $*
  <</
  - end
  
and use it in your code:

  -if <condition>

and it do automatic closing   
  

== SYNOPSIS:

=== HAML Like Syntax

just use it like haml basic, and if alredy comfort with that syntax you 
can extend the syntax and combine it with patern definition created in hot
file or you can create your own hot file.

==== Example 1 - HAML:

  #content
    %h1 menu
    %ul
      %li menu 1
      %li menu 2
      
will produce

  <div id="content">
    <h1>menu</h1>
    <ul>
      <li>menu 1</li>
      <li>menu 2</li>
    </ul>
  </div>

Extended syntax that produce the same result

  #content
    %h1 menu
    %ul
      ^{menu 1; menu 2}

or if <ul> patern is so common, it can be save in a hot file 
and use it as hot command. Example: inside "common.hot"

  >>ul
  %ul
    ^{$*}

and code in source:

  !hot!common
  #content
    %h1 menu
    %ul menu 1; menu 2

==== Example 2 - Form input

HAML format:

  %h1
    New user

  = error_messages_for :user 

  -form_for(@user) do |f| 
    %p
      %b Name
      %br
      = f.text_field :name 
    %p
      %b Email
      %br
      = f.text_field :email 
    %p
      %b Last login
      %br
      = f.datetime_select :last_login 

    %p
      = f.submit "Create"
  = link_to 'Back', users_path 

You can see that it not DRY, some patern will go to HOT files "rails_basic.hot"

  >>form_for
  - form_for($0) do |f| 
  <</
  - end

  >>input
  %p
    %b :capitalize$0
    %br
    = f.text_field :$0

  >>submit
  !/
  %p
    = f.submit "$0"

and code in source:

  !hot!rails_basic
  %h1 New user

  = error_messages_for :user 

  %form_for @user
    %input name;email;last_login
    %submit Create

  = link_to 'Back', users_path 

== REQUIREMENTS:

no requirement for now, since it use only regular experssion to do
parsing.

== INSTALL:

sudo gem install w2tags

=== COMMAND LINE

get it from commandline "w2tags"

  How to WaytoTags:
  ~~~~~~~~~~~~~~~~~~~~~~~
  syntax:
  w2tags [*.w2htm] [-a] [-d:*opt*]
  OR
  w2tags [file1,file2,file3] [-b] [-d:*opt*]

  example:
  1. w2tags -a             #=> translate all file with ext: w2htm
  2. w2tags *.w2xml -a     #=> translate all file with ext: w2xml
  3. w2tags file1.w2htm    #=> translate a file
  4. w2tags file1.w2htm -b #=> translate a file with no initialize/finalize
  5. w2tags file1.w2htm -d:parser #=> translate with debug parser
  6. w2tags file1.w2htm -d:constanta #=> translate with debug constanta
  7. w2tags file1.w2htm -d:stack #=> translate with debug stack indentation

  Enjoy... 

=== RAILS HOOK

add inside file "config/environment.rb" in the bottom:

  require 'w2tags'
  require 'w2tags/rails_hook'

=== MERB HOOK

add inside file "config/init.rb" in the bottom:

  require 'w2tags'
  require 'w2tags/merb_hook'
  
=== SINATRA HOOK

sinatra usualy consist only one file "main.rb", so just add below sinatra require:

  require 'w2tags'
  require 'w2tags/sinatra_hook'

== LICENSE:

Copyright (c) 2008 Widi Harsojo, wharsojo<at>gmail.com

Distributed under the user's choice of the {GPL Version 2}[http://www.gnu.org/licenses/old-licenses/gpl-2.0.html] (see COPYING for details) or the
{Ruby software license}[http://www.ruby-lang.org/en/LICENSE.txt] by Widi Harsojo.
