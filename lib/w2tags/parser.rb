module W2Tags 
  # Copyright (c) 2008 - 2009 Widi Harsojo
  class Parser
    attr_accessor :silent
    #change debuging ex: obj.dbg[:parse] = true
    attr_accessor :dbg 
    #set extention for ext auto loading HOT files 
    attr_accessor :ext 
    attr_reader   :spc
 
    block= ::W2Tags::Block.constants
    include *(block.collect{|m|eval("::W2Tags::Block::#{m.to_s}")})
    #initiall create instance object, default if no arguments will be 
    #target for html
    def initialize(mrg = nil)
      @dbg={
        :hot      =>nil,
        :stack    =>nil,
        :parse    =>nil,
        :constanta=>nil
      }
      
      #regex for w2tags   
      @rg_tag = [
      /^[ \t]*(%)([!]?[\w\-&\/:#.\[\]]+\{.*\}[=]*)!([^\n]*)\n/,
      /^[ \t]*(%)([!]?[\w\-&\/:#.\[\]=]+)!([^\n]*)([\n])/]
      
      #regex for function tags    
      @rg_hot = [
      /(%)([!]?[ \t\$\w\-&\/:#.\[\]%=]+\{.*\}[=]*)~([^\n]*)\n/,
      /(%)([!]?[ \t\$\w\-&\/:#.\[\]%=]+)~([^\n]*)\n/    ]
      @rgx    =  nil   #current regular expression
      @mrg    =  mrg   #another hot to include
      @ext    = 'erb'  #target extension 
      @hot    = 'hot'  #source of file hot
      @src_path= ''    #path for source file
      @silent = false  #for test

      @ron    = 0      #strip current source line if size it empty or not
      @spc    = ''     #current begining space of current source line
      @ind    = '  '   #indentation size
      @row    = 'row'  #current source line
      @key    = 'key'  #key extracted from regex function

      @mem_hot= nil    #@tg_nex will be use (for "%") if this var == nil
      @mem_tag= {'^'=>"%div$*!"} #get memorize of w2tag 
      @mem_var= {'$me'=>"wharsojo"}
      @mem_var['$basepath'] = File.basename(File.expand_path('.'))

      @tg_hot = {}     #{'div'=>[proc{|this|"%div$*!"},nil]} #collection of tag_hot after reading from source hot
      @tg_nex = {}     #tag next activate on shortcut tag "%"
      @tg_end = []     #momorize tag end from regex function
      @doc_src= []
      @doc_out= []
      
      @tagr = proc do |this|
        @key.strip!
        tags_created =  "<#{@key}"
        tags_created << " #{@mem_var["*all*"].strip}" if @mem_var["*all*"]!='' 
        #tags_created << " #{@att}" if @att!=''
        if @txt=='/'
          tags_created << "/>\n"
        else
          tags_created << '>'
          @ln_end = " "            
          if @txt=='' 
            @tg_end.push "#{@spc}</#{@key}>#{@ln_end}"
            p "Stack: #{@tg_end}" if @dbg[:stack]
          else
            if @txt.gsub!(/\<$/,'')
              @tg_end.push "#{@spc}</#{@key}>#{@ln_end}"
            else
              @ln_end = "</#{@key}>#{@ln_end}"
            end
            if @mem_var["*code*"] && @mem_var["*code*"]!=''
              tags_created << @mem_var["*code*"].gsub('$*',@txt)
            else
              tags_created << @txt.gsub(/^ +/,'') #remove gsub if don't want auto trim left
            end
          end
        end
        tags_created
      end
      @skiper= []
      public_methods.each do |f|
        send(f) if /_initialize$/ =~ (meth= f.to_s)
        @skiper << [$1,'_skip'].join.to_sym if /(.*)_skip$/ =~ meth
      end
    end
    
    #it use to clean all the definition and reloading the hot file
    def parse_init
      @tg_end   = [] #momorize tag end from regex function
      @doc_src  = []
      @doc_out  = []
      @tg_hot   = {} 
      merge_tags @mrg ? @mrg : @ext
      next_tag_init
    end
    
    def next_tag_init
      @tg_nex['html'  ]= [0,proc { @mem_tag["^"] = "%head $*\n"}]
      @tg_nex['head'  ]= [0,proc { @mem_tag["^"] = "%body $*\n"}]
      @tg_nex['ol'    ]= [0,proc { @mem_tag["^"] = "%li $0\n"  }]
      @tg_nex['ul'    ]= [0,proc { @mem_tag["^"] = "%li $0\n"  }]
      @tg_nex['dl'    ]= [0,proc { @mem_tag["^"] = "%dt $0\n"  }]
      @tg_nex['dd'    ]= [0,proc { @mem_tag["^"] = "%dt $0\n"  }]
      @tg_nex['form'  ]= [0,proc { @mem_tag["^"] = "%input $0\n"}]
      @tg_nex['select']= [0,proc { @mem_tag["^"] = "%option $0\n"}]
      @tg_nex['table' ]= [0,proc { @tg_nex['tr'][0]= 0 }]
      @tg_nex['tr'    ]= [0,proc { 
         @tg_nex['tr'   ][0]+= 1
         if @tg_nex['tr'][0]== 1
            @mem_tag["^"] = "%th $0\n" 
         else
            @mem_tag["^"] = "%td $0\n"
         end
      }]
    end

    def read_w2tags(src,spc=nil)
      src = src.delete("\r").split(/\n\>\>\>W2TAGS\>\>\>/)
      @tg_hot.merge!(W2Tags.parsing_hot(src.shift)) if src.length>1
      (spc ? src[0].gsub("\n","\n"+@spc) : src[0]) 
    end
    #parsing from fullpath source to the fullpath target/result
    #with the option of auto add 'initialize' and 'finalize'
    #for source file in w2tags only fill with LF it will not
    #translate, since behaviour for "\n\n\n".split("\n")
    #will result in empty array
    #if hot available it will add w2tags in:
    #firstline with @initialize()
    #lastline  with @finalize()
    #to not add, supply this function with init_start=false
    #ex: parsing("t.w2tst","t.tst",false)
    def parsing(src,tgt,init_start=true)
      puts ">>#{src}"
      puts ">>#{tgt}"
      parse_init
      @src_path= File.dirname(src)
      @doc_src = read_w2tags(IO.read(src)).split("\n")
      @doc_src<< "%finallize" if @tg_hot['finallize' ]
      
      while (@row = @doc_src.shift) do  #;p "row:#{@row}"
        if init_start && !(/!hot!/ =~ @row)
          @doc_src,@row = [[@row]+@doc_src,"%initialize"] if @tg_hot['initialize']
          p "HEAD:#{init_start}"
          init_start  = false
        end
        parse_row
      end
      if @dbg[:constanta] 
        p "const_ "
        @mem_var.keys.sort.each {|k|p "#{k.ljust 10} : #{@mem_var[k]}"}
      end
      
      if @dbg[:hot]
        @tg_hot.keys.sort.each_with_index do |v,i|
          puts "hot keys: #{i}. #{v}"
        end
      end
      
      open(tgt,'w') do |f|
        @doc_out.each do |row|
          f << row
        end
      end
      
    end
    
    #to test parsing on source line and return will be the result, 
    #everytime it execude, it clean up and reloading the HOT files.
    def parse_line row,init=true
      parse_init if init
      dbg[:parse]= false
      @doc_src   = read_w2tags(row).split("\n") << ",/"
      #@doc_src   = row.delete("\r").split("\n") << ",/"
      while (@row= @doc_src.shift) do  #;p "row:#{@row}"
        parse_row
      end
      @doc_out
    end
    
    #the actual parsing on row, but it use for parsing the files not to
    #test the source line, since some of the row have a command that 
    #has effect on source, result and the row will be empty, please use
    #parse_line if you want to test interactively on IRB.
    def parse_row row=nil
        @row = row if row
        @row<<"\n"           #;p "row:#{@row}"
        p "_____> #{@row}" if @dbg[:parse] && @plt == 99 && @rmk == 99

        parse_spc
        
        @ln_end = ""        #imediate ends tag
        @row.gsub!(/\\\\/,'')  #esc char \\
        @row.gsub!('\}','')    #esc char \}
        @row.gsub!('\;','')    #esc char \;
        while (parse_all) do; end  
        @row.gsub!('','\\')
        @row.gsub!('','}')
        @row.gsub!('',';')
        if @ln_end!=""
          @row.gsub!(/([\n\t ]*$)/,'')
          @row << "#{@ln_end.strip}\n"
        end
        if @row.strip!="" # responsible for generating good output
          p "#####> #{@row}" if @dbg[:parse] 
          @doc_out << (@row.rstrip + "\n") 
          #@doc_out << @row.rstrip # not working for 
          #@doc_out << "\n"        # shortcut if elsif else 
        end
        @row
    end

    #parse one w2tags, result will be name of the target file created
    def parse_file(src,init_start=true,chk_date=false)
      tgt,@ext = [src[/(.+\.)w2(\w+)$/,1]<<$2,$2]
      
      return nil if !File.exist?(src) #p "src: #{src} not found..."
      if chk_date && File.exist?(tgt)
        return nil if File.mtime(src) <= File.mtime(tgt)
      end
      
      puts "\nParsing W2Tags File:#{src}" 
      parsing(src,tgt,init_start)
      tgt
    end
    
    #parse multiple w2tags files, result will be array of target file created
    def parse_files(srcs,init_start=true)
      srcs.collect do |src|
        src.gsub!(/\n/,'')
        parse_file(src,init_start)
      end.compact
    end
    
    def end_tags(arr)
      @tg_end = @tg_end + arr
    end
    
    #call from proc hot before it render hots line
    #see in source code "w2tags.rb::read_filehot"
    #default behaviour for tag_nex will not execute
    #since @mem_hot will assigned w/o nil
    #assigned nil using "%!" in w2tags 
    def chg_mem_hot(nxt)
      @mem_hot      = nxt      
      @mem_tag["^"] = nxt if nxt
    end
    
    #pop up end tags from the stack 
    #result will be string contains end tags from stack 
    #who's space inside each end tags > current space
    def multi_end(ttls)
      rpls = ''
      ttl  = @tg_end.size-1
      ttl  = ttls-1 if ttls
      ttl.downto(0) do |i|
        sz = @tg_end[i][/^ +/].to_s.size
        if ttls || @spc.size <= sz
          send = @tg_end.pop.to_s
          if send.strip[0,5]=="!run!"
            scrpt = send.gsub("\n","\n#{@spc}").split("\n")
            @doc_src = scrpt[1,99]+@doc_src
          else
            spc = send[/(^[ \t]*)/,1].to_s
            rpls << send.gsub(/\n/,"\n#{spc}") + "\n" 
          end
        end
      end
      p "End..: #{rpls.strip}" if @dbg[:parse] && rpls!= ''
      rpls
    end
    
    private 

    # try to shift empty line create document and add current 
    # row to source. but it means re parsing current row.
    def swap_last_empt_src_with_end_tg(end_tg)
      while @doc_out[-1] && @doc_out[-1].strip == ''
        @doc_out.pop
      end
      @doc_out<< "\n" if @doc_out[-1] && @doc_out[-1][-1,1] != "\n" # responsible for generating good output
      end_tg.shift if end_tg[0].strip==''
      @doc_src = end_tg + @doc_src #; p @doc_src; p @doc_out
      #p "Swp..: #{@doc_src[-1]}" if @dbg[:parse] 
    end
    
    #merging file hot based on the target extension, and target 
    #extension it self based on source extension, example: 
    #suppose you have source of w2tags 'index.html.w2erb'    
    #it just like autoloading:
    # !hot!erb
    #it will search HOT files in current folder, if it not found 
    #it will search in gem/hot and merging the HOT
    def merge_tags(ext) 
      hot1 = "#{@src_path}/#{ext}.#{@hot}"
      hot2 = "#{W2Tags::Dir}/../hot/#{ext}.#{@hot}"
      filehot = hot1 if File.exist?(hot1)
      filehot = hot2 if File.exist?(hot2)
      if filehot
        puts '=>'+File.expand_path(filehot) if !@silent
        @tg_hot.merge!(W2Tags.read_filehot(filehot)) 
      end
      @tg_hot
    end
    
    #define variable ( &var! or @var! )tobe use by parser in hot for 
    #the next line parsing, example on w2tags: 
    #  &myvar=hello\n
    #  ^{.myclass &myvar!}
    #
    #it will translate on the fly to:
    #  ^{.myclass hello}
    #
    #for @var! is uniq value split by ";", example on w2tags:
    #  @myvar=hello;world\n
    #  @myvar=world;tags\n
    #  ^{.myclass @myvar!}
    #
    #it will translate on the fly to:
    #  ^{.myclass hello;world;tags}
    def parse_set_var
      if @row.gsub!(   /^[ \t]*(&[\w]+)=([^\n]+)([\n])/,'')
        @mem_var[$1+"!"] = $2.strip
      elsif @row.gsub!(/^[ \t]*(@[\w]+)=([^\n]+)([\n])/,'')
        k,v = [$1+"!",$2.strip] #;p v
        #v << ';'+@mem_var[k].to_s if v[0,1]!=';' && @mem_var[k]
        v = (@mem_var[k].to_s + ';' + v) if v[0,1]!=';' && @mem_var[k]
        @mem_var[k] = v.split(';').uniq.select{|x|x!=''}.join(';')
        p "uniqV> #{v}" if @dbg[:parse] #&& @plt == 99 && @rmk == 99
      end
    end
    
    #when parsing and found tag
    # !hot!filehot1;filehotN
    #it will search HOT files in current folder, if it not found it will search
    #in gem/hot and merging the HOT, this command can have multiple
    #file HOT separate with ";"
    def merge_hot
      if(/!hot! *([\w;.\/]+)([\n])/ =~ @row;@rgx = $~)
        hots= @rgx[1].split(';').collect {|x|x+'.'+@hot}
        rpl = ['']
        hots.each do |hot|
          fls = File.exist?(hot)                        ? hot :
                File.exist?(@src_path+'/'+hot)          ? @src_path+'/'+hot :
                File.exist?(W2Tags::Dir+'/../hot/'+hot) ? W2Tags::Dir+'/../hot/'+hot : ''
          if fls==''
            rpl << "<!--"+hot+", Not Found-->\n"
          else
            puts '=>'+File.expand_path(fls) if !@silent
            @tg_hot.merge!(W2Tags.read_filehot(fls))
          end  
        end
        @row.gsub!(@rgx.to_s,rpl.join)
      end
    end
    
    #when parsing and found tag 
    # !inc!fileinc
    #it will include / replace current row from file include, and after 
    #parser will try to get current row after merging to be evaluate
    def merge_w2x
      if(/!inc! *([\/\w\d._]+)([\n])/ =~ @row;@rgx = $~)
        mac = @src_path+'/'+$1 
        src = $~.to_s #;p mac
        if File.exist?(mac)
          pop = $~.captures.pop
          #new = IO.read(mac).delete("\r").gsub("\n","\n"+@spc) 
          new = read_w2tags(IO.read(mac))
          @doc_src= @row.gsub(src,new).split("\n")+@doc_src
          @row= @doc_src.shift+"\n"
          parse_spc
        else
          @row.gsub!(src,"<!--"+mac+", Not Found-->\n") 
          nil
        end
      end
    end
    
    #get space (tab and spaces) on the left of the code and save it to instance
    #it will be use if row replace with more than one row and replacement row
    #must continue with current column (indent). 
    def parse_spc
      @spc = @row[/(^[ \t]+)/,1].to_s       #sometime result is nil
      @ron = @row.strip.size
    end
    
    #do the translation from the params inside function like:
    # %a par1;par2;par3
    #it do following job:
    # * replace constanta (&var!) inside params of the function
    # * replace constanta (&var!) inside new line of source code 
    #   (inside instance var @new)
    # * replace var $0 - $9 inside var @new from params if function have
    #   3 params so 3 var $ will be replace from the params and if var @new
    #   have var # more than what function params suply, it will replace with
    #   an empty string
    # * if in var @new define only 1 var $ and function params got more than 
    #   1, it will multiply the @new line with total number of lparams
    #   to get the illustrate I'll show you with an example:
    #   inside hot file :
    #   >>td
    #   <td>$0</td>
    #   --------------------
    #   function call: @td(col1;col2) # will result in 
    #   --------------------
    #   <td>col1</td>
    #   <td>col2</td>
    # * some of the replacement behaviour for var $ are :
    #   1. optional meaning that var $ inside [ xxx $ xxxx ] sequare bracket are
    #      optional if not suply from params it will an emppty replacement
    #   2. default value meaning that var $ inside [ xxx $ left sequare bracket
    #      are a default if not suply from params but if it suply from params it
    #      will empty the default and relace var $ from the params
    #   3. execute String.method if var $ in the left got ":", example
    #      inside hot file:
    #      >>td
    #      <td>:capitalize$0</td> 
    #      --------------------
    #      function call: @td(col1;col2) # will result in 
    #      --------------------
    #      <td>Col1</td>
    #      <td>Col2</td>
    def get_dollar(prms,ends=nil) #prms='@0;@1;@2' from hot
      @mem_var.each do |k,v|            #;p "#{k}, #{v}"
        prms.gsub!(k,v)
        if k[0,1]=='*' and Regexp.new("~([^~]+)~#{k}".gsub('*','\\*')) =~ @new
          @new.gsub!($~.to_s,(v!='' ? v : $1)) 
        else
          @new.gsub!(k,v)
        end
      end
      prms.gsub!(/\\\\/,'')  #esc char \\
      prms.gsub!('\}','')    #esc char \}
      prms.gsub!('\;','')    #esc char \;
      prms = prms.split(';') #W2Tags::splitter(prms)
      new_prms = @new.scan(/\$[0-9]/).uniq
      new_alls = @new.scan(/\$\*/)        #;p 'rpl:',new_alls,new_prms,prms
      @new.gsub!($1,"<%= \"#{$2}\" %>") if /(==(\$[0-9]))/ =~ @new
      @new.gsub!($1,"<%= #{$2} %>")     if  /(=(\$[0-9]))/ =~ @new
      if /^@[0-9]$/ =~ prms[0]
        rpl = prms.shift.gsub('@','$')
        repeat = @new
        repeat.gsub!('$0',prms.shift)     #repeat.gsub!('$*',rpl)
        @new   = ''
        prms.each_with_index do |x,i|     #;p "$0 #{x} => #{repeat}"
          @new += repeat.gsub(rpl,x)
          if i+1<prms.size
            @new += "\n"+@spc+ends.join("\n") if ends 
            @new += "\n"+@spc 
          end
        end
        p "Rept1: #{@new}" if @dbg[:parse] 
      elsif new_alls==[] && new_prms.size==1 && prms.size>1 
        tmp = ""
        rpt = @rgx.to_s.gsub(@rgx[3]+"\n","")
        #multi key params(class,attribute,etc)
        classs = rpt[/([.:#].*\{.*?\}.*?) /,1] 
        classs = rpt[/(\{.*?\}.*?) /,1] if !classs 
        classs = rpt[/([.:#].*?) /,1]   if !classs 
        classs.sub!(/=$/,'') if classs
        clsmlt = classs.to_s.split(';')
        clscnt = clsmlt.length
        clsmlt+= clscnt==1 ? clsmlt*prms.length : ['']*prms.length
        prms.each_with_index do |x,i|
          y = x.strip
          if /^~[-%]/ =~ y
             tmp<<  y[1,y.length-1]
             tmp<< "\n#{@spc}" if i+1<prms.size
          else
             line = rpt+x #tmp<< @new.gsub(new_prms[0],x) 
             #implement multi class params ^.d;.g canggh;bow
             line.gsub!(classs,clsmlt[i]) if classs
             tmp<< line
             tmp<< "\n#{@spc}" if i+1<prms.size
          end
        end
        p "Rept2: #{tmp}" if @dbg[:parse] 
        @new = tmp
      else
        i = new_prms.size - 1
        new_prms.sort.reverse.each do |x|
          while Regexp.new('\\'+x+':(\d+)') =~ "\n#{@new}" do
            idx = $1
            src = $~.to_s
            rpl = idx ? prms[i].split(':')[idx.to_i].to_s.strip : ''
            p "Splt : #{prms[i]} => #{idx}" if @dbg[:parse] 
            @new.gsub!(src,rpl)
          end
         
          rgx = '\\'+x+'\.([^~ ]+)~'     #/\$0\.([^~ ]~)/ => fix: next-tag (~^)
          eva_v = Regexp.new(rgx)        #Ex:$1.upcase~
          while eva_v=~ "\n#{@new}" do
            src = "#{x}.#{$1}~"          #p "\n#{@new} => #{src}"
            evl = "\"#{prms[i]}\".#{$1}" #p "====> #{evl} <=="
            p "Eval : #{evl}" if @dbg[:parse] 
            rpl =  prms[i] ? eval(evl).to_s : ""
            @new.gsub!(src,rpl)
          end
         
          opt_v = Regexp.new('~([^$]*)\\' +x+'([^~]*)~') 
          def_v = Regexp.new('~([^~]+)~\\'+x) 
          if opt_v =~ @new #;p $1
            rpl = ''
            rpl = "#{$1.to_s}#{prms[i]}#{$2.to_s}" if prms[i] && prms[i].strip!=""
            @new.gsub!(opt_v,rpl)
            #p "options: #{rpl} >> #{@new}"
          elsif def_v =~ @new #;p $1
            src = $~.to_s
            rpl = (prms[i] && prms[i].strip!="" ? prms[i] : $1)
            @new.gsub!(src,rpl) 
            #p "default: #{@new}"
          end
          #p "rest: #{x} => #{prms[i].to_s}"
          @new.gsub!(x,prms[i].to_s)
          i = i -1
        end
        @new.gsub!(/\$\*/,prms[new_prms.size,99].to_a.join(';') )
        @new.gsub!(/\n\t+$/,'') #remove line if only tabs
      end
    end
    
    #pop up end tags from the stack 
    def multi_end2(ttls)
      rpls = ''
      ttl  = @tg_end.size-1
      ttl  = ttls-1 if ttls
      ttl.downto(0) do |i|
        sz = @tg_end[i][/^ +/].to_s.size
        if ttls || @spc.size <= sz
          send = @tg_end.pop
          if send.strip[0,5]=="!run!"
            scrpt = send.gsub("\n","\n#{@spc}").split("\n")
            @doc_src = scrpt[1,99]+@doc_src
          else
            spc = send[/(^[ \t]*)/,1].to_s
            rpls << (send.gsub("\n","\n#{spc}") + "\n") 
          end
        end
      end
      p "End2 : #{rpls}" if @dbg[:parse] && rpls!= ''
      rpls
    end
    
    #command execution "-key", internally parsed to "%_key~", so both command
    #are the same except that command "-key" need to translate to "%_key~" and
    #it goes to Hot files key definition to lookup to. some of these definition
    # built in (for erb: %_if , %_elsif , %_else , %_end , ... etc)
    #  -if  =>  %_if
    #  -li  =>  %_li
    def shortcut_exec(regex)
      if(regex =~ @row;@rgx = $~)
        srcs = @rgx.to_s
        rplc = "#{@rgx[1]}%!_#{@rgx[2]}~ #{@rgx[3]}\n"
        @row.gsub!(srcs,rplc)
        p "reExe_ #{@row}" if @dbg[:parse]
      end
    end
    
    #command execution "=", internally parsed to "%=~", so both command
    #are the same except that command "=" need to translate to "%=~" and
    #it goes to Hot files key definition to lookup to. you can redefine it.
    def shortcut_equal(regex)
      if(regex =~ @row;@rgx = $~)
        srcs = @rgx.to_s
        rplc = "#{@rgx[1]}%!=~#{@rgx[3]}\n"
        @row.gsub!(srcs,rplc)
        p "reEqu_ #{rplc}" if @dbg[:parse]
      end
    end
    
    #this command is the selector from command 
    # %..key.. params1;paramsN \n
    #ex: 
    # %div<space>params\n  or %div<\n>. 
    #if key div fine in hot, it will translate to HOT tags, but if not 
    #it become w2tags
    def get_hot_simple(regex)
      if regex =~ @row ;@rgx = $~ 
        chk1= @rgx[2][-1,1] + @rgx[3][0,2].to_s 
        chk2= @rgx[2][/"\}!/]
        chk3= @rgx[2][/"\}~/]
        # already become w2tags, ignore!!!
        if (/[=\}][!~][ ]?/ !~ chk1 && chk2 == nil && chk3 == nil) 
          keys = @rgx[2].strip
          opts = @rgx[3]
          #p chk1
          # FIX for: 
          # %form#dodol{action="<%= #{aaa} %>"} <%= #{bbb} %>
          # <form id="dodol" action="<%= #{aaa} %>"><%= #{bbb}%></form>
          # when wrong splitting, fix the splitting...
          # assume last attribute don't have spaceses!!! ==>{opt="blah"}<==
          fixd = keys.split('"} ')
          if fixd.length>1
            keys = fixd[0]+'"}'
            opts = fixd[1]+opts
          end
          
          srcs = @rgx.captures.join
          opts = $1 << opts if keys.gsub!(/(\/)$/,'')
          hots = keys.gsub(/\{.*\}$/,'').gsub(/[:#.][\w\-#.=]*$/,'')
          rplc = @tg_hot[hots]!=nil ? 
          "%!#{keys}~ #{opts}" : 
          "%!#{keys}! #{opts}" 
          @row.gsub!(srcs,rplc)
          p "reHot> #{@row} << -H-O-T-" if @dbg[:parse]
        end
      end
    end
    
    #translation for tags with shortcut of name, id, or class and put in constants
    # ex: %div:name#id.class{attribute}=
    #will result in some of this var:
    # @mem_var['$$'     ] => :name#id.class{attribute}==
    # @mem_var['$:'     ] => :name
    # @mem_var['$#'     ] => #id
    # @mem_var['$.'     ] => .class
    # @mem_var['$@'     ] => {attribute}
    # @mem_var['*:'     ] => name
    # @mem_var['*#'     ] => id
    # @mem_var['*.'     ] => class
    # @mem_var['*@'     ] => attribute
    # @mem_var['*all*'  ] => name="name" id="id" class="class"
    # @mem_var['*name*' ] => name="name"
    # @mem_var['*id*'   ] => id="id"
    # @mem_var['*class*'] => class="class"
    # this var will be use in parsing w2tags/hot command
    def nameidclass_var()
      #@key = keys = @rgx[2].strip.gsub(/(\{(.*)\})/,'') #greedy :)
      @key = keys = @key.strip.gsub(/(\{(.*)\})(=*)/,'') #greedy :)
      @att = $2.to_s.strip
      lkey = $3.to_s.strip
      @mem_var['$$'     ]= ''
      @mem_var['$&'     ]= ''
      @mem_var['$:'     ]= ''
      @mem_var['$#'     ]= ''
      @mem_var['$.'     ]= ''
      @mem_var['$@'     ]= $1.to_s
      @mem_var['$='     ]= ''
      @mem_var['*&'     ]= ''
      @mem_var['*:'     ]= ''
      @mem_var['*#'     ]= ''
      @mem_var['*.'     ]= ''
      @mem_var['*@'     ]= @att=='' ? '' : @att+' '
      @mem_var['*all*'  ]= ''
      @mem_var['*name*' ]= ''
      @mem_var['*id*'   ]= ''
      @mem_var['*class*']= ''
      @mem_var['*code*' ]= ''
      #p keys
      if @key.gsub!(/([:#.&=])([\/\t\w\-#.\[\]&= ]*$)/,'')
        keys = $1+$2
        @mem_var['$$'] = keys.clone
        if keys.gsub!(/^:([\w\-.\[\]]*)/,'')
          if $1!=''
            @mem_var['$:'     ] = ":#{$1}"
            @mem_var['*:'     ] = $1
            @mem_var['*name*' ] = "name=\"#{$1}\" " 
            @mem_var['*all*'  ]<< "name=\"#{$1}\" " 
          end  
        end
        if keys.gsub!(/^#([\w\-]*)/,'')
          if $1!=''
            @mem_var['$#'     ] = "##{$1}"
            @mem_var['*#'     ] = $1
            @mem_var['*id*'   ] = "id=\"#{$1}\" " 
            @mem_var['*all*'  ]<< "id=\"#{$1}\" " 
          end  
        end
        if keys.gsub!(/^\.([\w\-\.]*)/,'')
          if $1!=''
            cl = $1
            cx = cl.split('.').collect {|x|x.strip}.join(' ')
            @mem_var['$.'     ] = ".#{cl}"
            @mem_var['*.'     ] = cx
            @mem_var['*class*'] = "class=\"#{cx}\" "
            @mem_var['*all*'  ]<< "class=\"#{cx}\" "
          end  
        end
        if keys.gsub!(/^&([\/\w\-.]*)/,'')
          if $1!=''
            @mem_var['$&'     ] = "&#{$1}"
            @mem_var['*&'     ] = $1
          end  
        end
        @key << keys
      end
      @mem_var['*all*'] << @mem_var['*@']
      @mem_var['*att*']  = @mem_var['*@']
      if @key[0,1]!='='
        @key << lkey
        if @key.gsub!(/==+$/,'')
          @mem_var['*code*'] = '<%= "$*" %>'
          @mem_var['$@']<< "=="
          @mem_var['$='] = "=="
        elsif @key.gsub!(/=$/,'')
          @mem_var['*code*'] = "<%= $* %>"
          @mem_var['$@']<< "="
          @mem_var['$='] = "="
        end
      end
    end
    
    #these not really visible for end user, since user usualy see the command as
    #a HAML like command and translate to this HOT files. the translation usually
    #came from method in:
    # shortcut_exec
    # get_hot_simple
    #format for this command is 
    # %...key...~..params1;paramsN..\n
    def parse_hot  
      eva = ''
      col = @row.split('%')
      return false if col.size==1
      (col.size-1).downto(0) do |c|
        eva = "%#{col[c]}" << eva
        @rg_hot.each do |ht|
          if(ht =~ eva;@rgx = $~)
            @key = @rgx[2]
            prms = @rgx[3].to_s.strip
            if /^\!/ =~ @key
              @new = (multi_end2(nil)+@spc+@rgx.to_s.gsub('%!','%')).split("\n")
              swap_last_empt_src_with_end_tg(@new) #@new array of src
              @row = ''
            else
              nameidclass_var()
              # Auto closing, see in "erb.hot": _elsif _else:
              # when last doc out is <% end %> and hot command is %_elsif or %_else
              # then remove the last doc out <% end %>
              if @doc_out[-1] and @doc_out[-1].strip=='<% end %>'
                 @doc_out.pop if %w[else elsif].include? prms.split(' ')[0]
              end
              params_inline prms #concenation line if params end with \
              @mem_var["$tag"] = @key
              if @tg_hot[@key]
                hots = @tg_hot[@key] 
                hots[1]='' if !hots[1]  #remark if not error!
                @new = hots[0].call(self).clone  
                if @new.strip=="" #&& @tg_end[-1]
                  @tg_end << "#{@spc}#{hots[1][0]}"
                  empt = @row.gsub!(@rgx.to_s,"").strip
                  @row = empt if empt == ""  #remove if empty (only \t,\n)
                else
                  @tg_end << "#{@spc}#{hots[1][0]}" if hots[1]
                  @new.gsub!(/( *~\^.*[^\n]+)/,"^~^~^")
                  setvar = $1 # don't parse SetMem ~^
                  @new.gsub!(/\n/,"\n#{@spc}")
                  get_dollar(prms,hots[1]) 
                  @new.gsub!(/\^~\^~\^/,setvar) if setvar #restore SetMem
                  re_indent(@rgx.to_s)
                end
                p "Func>> #{@new}" if @dbg[:parse]
              else
                @row.gsub!(@rgx.to_s,"<!-- no hot for:#{@key} -->")
              end
            end
            break
          end
        end
        break if @rgx
      end
      @rgx!=nil
    end
    
    def re_indent(srcs)
      new_rows = @row.gsub(srcs,@new).split("\n").select {|x|!(/^ *$/=~x)}
      while @doc_src[0] && /^ *$/ =~ @doc_src[0] #remove empty/space line
        @doc_src.shift
      end
      spc_row1 = (/[^ ]/ =~ new_rows[ 0]).to_i
      spc_last = (/[^ ]/ =~ new_rows[-1]).to_i
      spc_adds = spc_last - spc_row1 
      #p "SPACE ADD #{spc_row1} #{spc_last} #{(/[^ ]/ =~ @doc_src[0]).to_i}"
      #p new_rows
      #p [@doc_src[0]]
      if spc_adds > 0 
        idx = 0
        spc = ' '*spc_adds
        while @doc_src[idx] && (/[^ ]/ =~ @doc_src[idx]).to_i > spc_row1
          @doc_src[idx] = spc + @doc_src[idx]
          idx += 1
        end
      end 
      #@doc_src = @row.gsub(srcs,@new).split("\n")+@doc_src
      @doc_src = new_rows + @doc_src
      @row = @doc_src.shift+"\n"
      parse_spc
    end

    #internal use call from 
    #  get_div
    #  get_input
    def get_shortcut(regex,tag)
      if(regex =~ @row;@rgx = $~)
        src = @rgx.captures.join
        keys= @rgx[1,2].join.strip
        opts= @rgx[3].to_s
        opts= $1 << opts if keys.gsub!(/(\/)$/,'')
        #tgt = "%!#{tag}#{keys}!#{opts}"
        tgt = "%#{tag}#{keys} #{opts}"
        @row.gsub!(src,tgt)
        p "to#{tag.capitalize[0,3]}: #{tgt}" if @dbg[:parse]
      end
      @rgx!=nil
    end
    
    #shortcut for 
    # "%...div...!params", 
    #and user no need to write 
    # "%div" 
    #if user supply the command with ID or CLASS.
    # %div#key my key features   
    #same as:
    # #key my key features 
    #
    # %div.okey my key features   
    #same as:
    # .okey my key features 
    def get_div(  regex)
      get_shortcut(regex,'div')
    end
    
    #shortcut for 
    # "%...input...!params", 
    #and user no need to write 
    # "%input" 
    #if user supply the command with NAME
    # %input:wharsojo my key features   
    #same as:
    # :wharsojo my key features 
    def get_input(regex)
      get_shortcut(regex,'input')
    end
    
    #popup the closing tags when indentation are less than the previous.
    def auto_close
      if @tg_end.size>1
        sz = @tg_end[-1][/^ +/].to_s.size
        if @spc.size <= sz
           ed = multi_end(nil).rstrip
           p "AutE:#{ed}#{@row}" if @dbg[:parse]
           @doc_out += [ed,(@doc_out[-1].to_s[-1,1]=="\n" ? '' : "\n"),@row]
           @row = ''
          true
        end
      end
    end
    
    #all regex for line will be parse in this methods return value of not nill
    #will try to parse the line (@row) again, if finish parsing (return nil)
    #it try to check the indentation to auto_close the line.
    def parse_all
      #check for skipping the block using add on module...
      parse_spc
      if @skiper.select{|f|send(f)}.length>0
        p "skip > #{@row}" if @dbg[:parse]
      else
        @plt_opt= ''  
        #rtn= true if @selector.select{|f|send(f)}.length>0
        rtn = true if shortcut_exec( /(^[\t ]*)\-([\w\-&\/:#.%]*\{.*\}=*) *([^\n]*)\n/) 
        rtn = true if shortcut_exec( /(^[\t ]*)\-([\w\-&\/:#.%=]*) *([^\n]*)\n/) 
        rtn = true if shortcut_equal( /(^[\t ]*)=([\w\-&\/:#.%=]*) *([^\n]*)\n/) 
        
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w\-&\/:#.\[\]]+\{.*?\}[= ]*)([^\n]*)\n/)
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w\-&\/:#.\[\]]+\{.*?\}[= ]*)()\n/)
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w\-&\/:#.\[\]%=]+ )([^\n]*)\n/) 
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w\-&\/:#.\[\]%=]+)()\n/) 
        
        rtn = true if get_div(/^[\t ]*([#.])([\w\-&\/.]*\{.*\}[= ]*)([^\n]*)\n/)
        rtn = true if get_div(/^[\t ]*([#.])([\w\-&\/.]*\{.*\}[= ]*)()\n/)
        rtn = true if get_div(/^[\t ]*([#.])([\w\-&\/.=]* )([^\n]*)\n/) 
        rtn = true if get_div(/^[\t ]*([#.])([\w\-&\/.=]*)()\n/) 
        rtn = true if get_input( /^[\t ]*(:)([\w\-&\/#.]*\{.*\}[= ]*)([^\n]*)\n/)
        rtn = true if get_input( /^[\t ]*(:)([\w\-&\/#.]*\{.*\}[= ]*)()\n/)
        rtn = true if get_input( /^[\t ]*(:)([\w\-&\/#.=]* )([^\n]*)\n/) 
        rtn = true if get_input( /^[\t ]*(:)([\w\-&\/#.=]*)()\n/) 
        rtn = true if parse_hot
        rtn = true if merge_hot
        rtn = true if merge_w2x
        rtn = true if parse_set_var
        rtn = true if parse_set_mem
        rtn = true if parse_get_mem
        rtn = true if inline_tag
        rtn = true if parse_end
        if parse_tags
           rtn = nil
        elsif !rtn
           auto_close 
        end
      end
      rtn
    end
    
    #remember command "^", not really use but if you want less typing you can
    #define this command inside HOT file for the next command to be execute like:
    # HOT file:
    # >>_tr
    # ~^%td
    #
    # Source file:
    # -tr
    #   ^ inside td
    #I think its Ok.
    def parse_set_mem
      if @row.gsub!(/([ \t]*~\^)([^\n]+\n)/,'')
         set_mem = $2  
         if !global_set_mem(set_mem)
            p "setMem ^ => #{set_mem}" if @dbg[:parse]
            @mem_tag["^"]= set_mem
         end 
      end
    end
    
    def global_set_mem(set_mem)
      return nil if !(/^%(\w+)([%-].+)/ =~ set_mem)
      @tg_nex[$1]= [0,proc { @mem_tag["^"] = $2}]
    end
    
    #remember command "^", not really use but if you want less typing you can
    #define this command inside HOT file for the next command to be execute like:
    # HOT file:
    # >>_tr
    # ~^%td
    #
    # Source file:
    # -tr
    #   ^ inside td
    #I think its Ok.
    def parse_get_mem
      if(/([\^*])([^ ]*) *([^\n]*)(\n)/ =~ @row;@rgx = $~)
        keys,tmp,prms,opt,ends= @rgx.captures
        if opt=='!'
          opt=''
          @mem_hot=nil
        end
        keys.sub!('*','^')
        params_inline prms #concenation line if params end with \
        @new = @mem_tag[keys].split(' ')
        @new[0] << tmp
        @new = @new.join(" ") << "\n"
        get_dollar(prms)
        rpl = @new #+opt.to_s+ends.to_s
        p "stMem> #{rpl}" if @dbg[:parse]
        @row.gsub!(@rgx.to_s,rpl)
        rows = @row.split("\n")     
        if rows.size>1
            @doc_src = rows+@doc_src
            @row = @doc_src.shift+"\n"
        end
      end
      @rgx!=nil
    end
    
    #it call from parse_end
    def get_end(regex)
      if(regex =~ @row;@rgx = $~)
        if @rgx[1]=='~' 
          @new = ''
          @new = multi_end(1) if @tg_end.size>0
        else
          case @rgx[1]
          when '!';@new = multi_end(nil)
          when ',';@new = multi_end(@tg_end.size)
          else    ;@new = multi_end(@rgx[1].size)
          end
        end
        @doc_src = @row.gsub(@rgx.to_s,@new).split("\n")+@doc_src
        @row = ''
      end
    end
    
    #user can popup the end tags using these folowing command:
    # ,/ all end tags will be popup
    # ~/ one or multi end tags will be popup (depend on how many ~ you write)
    # !/ popup until the same indentation of "!/"
    def parse_end
      (get_end(/^(,)\/(\n)/) ? true : \
      (get_end(/^[ \t]*(~+)\/(\n)/) ? true : \
       get_end(/^[ \t]*(!)\/(\n)/)))
    end

    #parsing w2tags commands
    def parse_tags
      @rgx = nil
      par  = []
      rgs  = @rg_tag.collect {|r|par << (r =~ @row);$~}
      if(max = par.compact.sort.pop)      #have any to parse?
        @rgx = rgs[par.index(max)]
        @key = @rgx[2]
        @txt = @rgx[3].strip
        
        # when wrong splitting, fix the splitting...
        # assume last attribute don't have spaceses!!! ==>{opt="blah"}<==
        fixd = @key.split('"} ')
        if fixd.length>1
          @key = fixd[0]+'"}'
          @txt = fixd[1]+@txt
        end
        
        if /^\!/ =~ @key
          @new = (multi_end(nil)+@rgx.to_s.gsub('%!','%')).split("\n")
          swap_last_empt_src_with_end_tg(@new)
          @row = ''
          p "W2Tag: try closing tag by indentation..." if @dbg[:parse]
          return true
        else
          params_inline @txt #concenation line if params end with \
          @mem_var["$tag"] = @key
          nameidclass_var()
          srcs = @rgx.to_s.gsub!(/^[ \t]*/,'')
          tag_next = @tg_nex[@key] #;p "%mem_hot:#{@mem_hot}:#{@key}"
          tag_next[1].call if tag_next && @mem_hot==nil
          rplc = @tagr.call(self); 
          @mem_var.each do |k,v|
            rplc.gsub!(k,v)
          end
          @row.gsub!(srcs,rplc)
        end
        p "W2Tag: #{@row}" if @dbg[:parse]
      end  
      @rgx!=nil
    end
    
    #inline parsing 
    #I Like (%strong.bold{banana="boys"} (%i.italic cake%)%)!
    #I Like <strong class="bold" banana="boys"><i class="italic">cake</i></strong>!
    def inline_tag()
      if(/\(%(.*?)%\)/ =~ @row;@rgx = $~)
        src = $1.split(/\(%/)
        txt = src.length>1 ? src.pop : src[0]
        tmp = txt.lstrip.split(' ')
        @key= tmp.shift
        @txt= tmp.join(" ")
        nameidclass_var()
        @key.strip!
        html= @mem_var["*code*"]
        html= html=='' ? @txt : html.gsub("$*",@txt)
        tags_created =  "<#{@key}"
        tags_created << " #{@mem_var["*all*"].strip}" if @mem_var["*all*"]!='' 
        tags_created << ">#{html}</#{@key}>"
        @row.gsub!("(%#{txt}%)",tags_created)
        p "InLin: #{@row}" if @dbg[:parse]
      end
      @rgx
    end
    
    #concenation line if params end with \
    def params_inline prms
      while prms[-1,1]=='\\' do 
        prms.gsub!(/\\$/,'') << @doc_src.shift.strip
      end
    end
  end  
end
