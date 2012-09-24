dir = File.dirname(__FILE__)
Dir["#{dir}/w2tags/block/*.rb"].each{|f|require f}
$LOAD_PATH << dir  unless $LOAD_PATH.include?(dir)

# = W2TAGS (Way to Tags)
#
# W2TAGS is a shortcut of tags, macros, and it is very simple describer for HTML
# its not to become a replacement for inline tamplating engine, it best use for 
# developement (sinatra / rails / merb) and the result is an "erb" file to be 
# execute by erb or erubis (the fastest templating engine). 
#
# It focus on how developer can code and generate dynamic content with 
# DRY philosophy, easy to understand and in a very clean way.
#
# == Features
#
# * Mimics HAML syntax (inherit features define in HAML)
# * Extended syntax for Next Tag, Variable, Constanta
# * HOT file is patern for put in repetitif code and leter can be call it
# * HOT Variable interpolation, make it code really DRY
#
# == Using W2TAGS
#
# some of the guide are inside
# * README.rdoc
# * doc/W2TAGS.rdoc
# * doc/HAML.rdoc
# * doc/FAQ.rdoc
# * doc/HOT.rdoc

module W2Tags
  Dir = File.dirname(__FILE__)
  VERSION = File.read(Dir + '/../VERSION').strip unless defined?(VERSION)
  
  #split string with aditional option escape charaters'\'
  def self.splitter(data,deli=';')
    tg_esc = data.split("\\"+deli)
    if  tg_esc.size > 1
      tg_esc = tg_esc.collect {|x|x.split(deli)}
      result = tg_esc.shift
      while  tg_esc != []
        token = tg_esc[0]
        result[-1,1] = result[-1,1][0] +';'+ token[0,1][0]
        result = result + token[1,99]
        tg_esc.shift
      end
    else
      result = data.split(deli)
    end
    result
  end
  
  #hot files is a collection of w2tags function
  #example of the function that will translate by this method
  #
  #  >>body
  #  <body>
  #  <</
  #  </body>
  #
  #and example of use that function
  #  @body()
  #    @div!Hello Tags
  #  ./
  #
  #it will produce
  #  <body>
  #   <div>Hello Tags</div>
  #  </body>
  def self.read_filehot(fhot)
    parsing_hot(IO.read(fhot).delete("\r"))
  end
  
  def self.parsing_hot(src)
    hot_new = {} 
    hot = ("\n"+src).split(/\n\>\>/)
    hot.shift
    hot.each do |item|
      item.gsub!(/\n([ \t]*)$/,'') #remove blank lines
      ends  = item.split(/\n\<\<\/[^\n]*\n/)  #hots | ends
      mems  = ends[0].split(/\n\!~[^\n]*\n/)  #hots | mems
      khot  = mems[0].split("\n")  #key  | hot
      keys  = khot.shift.rstrip    #hots  = mems[0].gsub(keys+"\n",'')
      hots  = khot.join("\n")
      hot   = [nil,nil]
      hot[0]= proc do |this| 
        this.chg_mem_hot(mems[1]) if this!= nil
        hots
      end
      if ends.size>1
        hot[1] = [ends[1]]
#      tend = splitter(ends[1])
#      if tend.size==1
#        hot[1] = [tend]
#      else
#        hot[1] = tend.collect {|x|"</#{x}>"}
#      end
      end 
      hot_new[keys] = hot
    end
    hot_new
end  
end
require 'w2tags/parser'

if Object.const_defined?(:Rails) && 
  Rails.version.match(/^3/) && 
  Rails.env == "development" 
  puts 'W2Tags Hooked on Rails 3.x !'

  module ActionView
    class PathResolver
      alias :w2query :query
      W2TAGS = W2Tags::Parser.new('rails')

      def query(path, details, formats)
        tpl = "app/views/#{path}.#{formats[0]}.w2erb"
        W2TAGS.parse_file(tpl, true, true)
        w2query(path, details, formats)
      end
    end
  end
  
end
