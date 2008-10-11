# Copyright (c) 2008 Widi Harsojo

module W2Tags 
  class Parser
    attr_reader   :spc
    attr_accessor :dbg 
    
    #initiall create instance object, default if no arguments will be 
    #target for htm
    def initialize(ext = '.htm')
      @dbg={
        :hot      =>nil,
        :stack    =>true,
        :parse    =>nil,
        :constanta=>nil
      }
      
      #regex for w2tags    
      @rg_tg = [
      /(%)([!]?[ \t\w:]+\{[^\}]*\}[#.=]?[^!]*)!([^`\n]*)([`\n])/,
      /(%)([!]?[ \t\w:]+[#.=]?[^!]*)!([^`\n]*)([`\n])/          ]
      
      #regex for function tags    
      @rg_ht = [
      /(%)([!]?[ \t\$\w\-\/:#.%=]+)~([^\n]*)\n()/,
      /(%)([!]?[ \t\$\w\-\/:#.%=]+)\{([^\}]*)\}([^!=])/]
      
      @plt    =  99    #remark indentation
      @rmk    =  99    #remark indentation
      @rgx    =  nil   #current regular expression
      @ext    = '.htm' #target extension 
      @hot    = 'hot'  #source of file hot
      @w2x    = 'w2x'  #source file to include
      @src_path= ''    #path for source file
      
      @spc    = ''     #current begining space of current source line
      @ind    = '  '   #indentation size
      @row    = 'row'  #current source line
      @key    = 'key'  #key extracted from regex function

      @mem_hot= nil    #@tg_nex will be use (for "%") if this var == nil
      @mem_tag= {'^'=>"%div$*!"} #get memorize of w2tag 
      @mem_var= {'$me'=>"wharsojo"}
      @mem_var['$basepath'] = File.basename(File.expand_path('.'))

      @tg_end = []     #momorize tag end from regex function
      @tg_hot = {}     #{'div'=>[proc{|this|"%div$*!"},nil]} #collection of tag_hot after reading from source hot
      @tg_nex = {}     #tag next activate on shortcut tag "%"
      
      @tg_nex['html'  ]= [0,proc { @mem_tag["^"] = '%!head!'}]
      @tg_nex['head'  ]= [0,proc { @mem_tag["^"] = '%!body!'}]
      @tg_nex['ol'    ]= [0,proc { @mem_tag["^"] = '%!li!$0'}]
      @tg_nex['ul'    ]= [0,proc { @mem_tag["^"] = '%!li!$0'}]
      @tg_nex['dl'    ]= [0,proc { @mem_tag["^"] = '%!dt!$0'}]
      @tg_nex['dt'    ]= [0,proc { @mem_tag["^"] = '%!dd!$0'}]
      @tg_nex['dd'    ]= [0,proc { @mem_tag["^"] = '%!dt!$0'}]
      @tg_nex['select']= [0,proc { @mem_tag["^"] = '%!option{value="$0" $1}!'  }]
      @tg_nex['form'  ]= [0,proc { @mem_tag["^"] = '%!input$0!/'  }]
      @tg_nex['table' ]= [0,proc { @tg_nex['tr'][0] = 0 ;@mem_tag["^"] = '%!th!$0'}]
      @tg_nex['tr'    ]= [0,proc { @tg_nex['tr'][0]+= 1
            @mem_tag["^"] =  @tg_nex['tr'][0]== 1 ? '%!th!$0' : '%!td!$0'
              }]

      @tagr = proc do |this|
        @key.strip!
        tags_created =  "<#{@key}"
        tags_created << " #{@mem_var["%all%"].strip}" if @mem_var["%all%"]!='' 
        tags_created << " #{@att}" if @att!=''
        if @txt=='/'
          tags_created << '/>'
        else
          tags_created << '>'
          if @txt==''
            @tg_end.push "#{@spc}</#{@key}>#{@ln_end}"
            @ln_end = ""            
            p "Stack: #{@tg_end}" if @dbg[:stack]
          else
            if @mem_var["%code%"] && @mem_var["%code%"]!=''
              tags_created << @mem_var["%code%"].gsub('$*',@txt)
            else
              tags_created << @txt
            end
            @ln_end = "</#{@key}>#{@ln_end}"
          end
        end
        tags_created
      end
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
      @src_path = File.dirname(src)
      @tg_end   = [] #momorize tag end from regex function
      @doc_out  = []
      merge_tags
      @doc_src = IO.read(src).split("\n")
      @doc_src<< "%finallize" if @tg_hot['finallize' ]
      while (@row = @doc_src.shift) do  #;p "row:#{@row}"
        if init_start && !(/!hot!/ =~ @row)
          @doc_src,@row = [[@row]+@doc_src,"%initialize"] if @tg_hot['initialize']
          p "HEAD:#{init_start}"
          init_start  = false
        end
        
        @row<<"\n"           #;p "row:#{@row}"
        p "_____> #{@row.strip}" if @dbg[:parse] && @plt == 99 && @rmk == 99

        parse_spc
        
        @ln_end = ""        #imediate ends tag
        @row.gsub!(/\\\\/,'')  #esc char \\
        @row.gsub!('\}','')    #esc char \)
        @row.gsub!('\;','')    #esc char \;
        while (parse_all) do; end  
        @row.gsub!('','\\')
        @row.gsub!('','}')
        @row.gsub!('',';')
        if @ln_end!=""
          @row.gsub!(/([\n\t ]*$)/,'')
          @row << "#{@ln_end}#{$1}\n"
        end
        p "#####> #{@row.strip}" if @dbg[:parse] && @plt == 99 && @rmk == 99
        
        @doc_out << @row
      end
      
      open(tgt,'w') do |f|
        @doc_out.each do |row|
          f << row
        end
      end
      
      if @dbg[:hot]
        @tg_hot.keys.sort.each_with_index do |v,i|
          puts "#{i}. #{v}"
        end
      end
    end
    
    #parse one w2tags, result will be name of the target file created
    def parse_file(src,init_start=true,chk_date=false)
      tgt,@ext = [src[/(.+\.)w2(\w+)$/,1]<<$2,$2]
      
      return nil if !File.exist?(src) #p "src: #{src} not found..."
      
      if chk_date && File.exist?(tgt)
        return nil if File.mtime(src) <= File.mtime(tgt)
      end
      puts "\nParsing W2Tags File:" 
      
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
#     rpls[@spc.size,99].to_s
      rpls
    end
    
    private 

    def swap_last_empt_src_with_end_tg(end_tg)
      last = []
      while @doc_out[-1] && @doc_out[-1].to_s.strip == ''
        last << @doc_out.pop
      end
      @doc_src = end_tg + @doc_src
    end
    
    #merging file hot based on the target extension, and target 
    #extension it self based on source extension, example: 
    #suppose you have source of w2tags 'index.html.w2erb'    
    #it will produce target extension of '.erb' and 
    #target file 'index.html.erb' and loding
    #hot file of 'erb.hot' from library
    def merge_tags 
      filehot = "#{W2Tags::Dir}/../hot/#{@ext}.#{@hot}"
      if File.exist?(filehot)
        p File.expand_path(filehot)
        @tg_hot.merge!(W2Tags.read_filehot(filehot)) 
      end
    end
    
    #define variable ( &var! or %var! )tobe use by parser in hot for 
    #the next line parsing, example on w2tags: 
    #  &myvar!hello\n
    #  ^{.myclass &myvar!}
    #
    #it will translate on the fly to:
    #  ^{.myclass hello}
    #
    #for %var! is uniq value split by ";", example on w2tags:
    #  @myvar!hello;world\n
    #  @myvar!world;tags\n
    #  ^{.myclass @myvar!}
    #
    #it will translate on the fly to:
    #  ^{.myclass hello;world;tags}
    def parse_set_var
      if @row.gsub!(   /^[ \t]*(&[\w]+!)([^\n]+)([\n])/,'')
        @mem_var[$1] = $2 
      elsif @row.gsub!(/^[ \t]*(@[\w]+!)([^\n]+)([\n])/,'')
        k,v = [$1,$2] #;p v
        v << ';'+@mem_var[k].to_s if v[0,1]!=';' && @mem_var[k]
        @mem_var[k] = v.split(';').uniq.select{|x|x!=''}.join(';')
      end
      p "const_ #{@mem_var.keys.join(', ')}" if @dbg[:constanta]
    end
    
    #same as merge_tags but this one call from w2tags file after parsing 
    #and found tag !hot!filehot, and it will do action like on merge_tags
    def merge_hot
      if(/!hot!([\w;]+)([`\n])/ =~ @row;@rgx = $~)
        hots= @rgx[1].split(';').collect {|x|x+'.'+@hot}
        rpl = ['']
        hots.each do |hot|
          if File.exist?(@src_path+'/'+hot)
            p "include hot: #{hot}"
            @tg_hot.merge!(W2Tags.read_filehot(@src_path+'/'+hot))
          elsif File.exist?( W2Tags::Dir+'/../hot/'+hot)
            p "include hot: #{hot}"
            @tg_hot.merge!(W2Tags.read_filehot(W2Tags::Dir+'/../hot/'+hot))
          else
            rpl << "<!--"+hot+", Not Found-->\n"
          end  
        end
        @row.gsub!(@rgx.to_s,rpl.join)
      end
    end
    
    #when parsing and found tag !inc!fileinc, it will include / replace 
    #current row from file inside .w2x, and after parser will try to get
    #current row after merging to be evaluate
    def merge_w2x
      if(/!inc![ ]?([\w.]+)([`\n])/ =~ @row;@rgx = $~)
        mac = @src_path+'/'+$1+'.'+@w2x
        src = $~.to_s #;p mac
        if File.exist?(mac)
          pop = $~.captures.pop
          new = IO.read(mac).gsub("\n","\n"+@spc) + ( pop=='`' ? "\n"+@spc : '' )
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
    end
    
    #do the translation from the params inside function like @a(par1;par2;par3)
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
        @new.gsub!(k,v)
      end
      prms = prms.split(';') #W2Tags::splitter(prms)
      new_prms = @new.scan(/\$[0-9]/).uniq
      new_alls = @new.scan(/\$\*/)        #;p 'rpl:',new_alls,new_prms,prms
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
      elsif new_alls==[] && new_prms.size==1 && prms.size>1 
        @new   = ''
        repeat = @rgx.to_s
        prms.each_with_index do |x,i|
          @new << repeat.gsub(@rgx[3],x)
          @new << @spc if i+1<prms.size
        end
      else
        i = new_prms.size - 1
        new_prms.sort.reverse.each do |x|
        opt_v = Regexp.new('\[([^\$]*)\\'+x+'([^\]]*)\]') 
        def_v = Regexp.new('\[([^\$]*)\\'+x) 
        eva_v = Regexp.new(':([\w]+)\\'  +x)     #exe methh: :upcase:$1 
          if opt_v =~ @new #;p $1
            @new.gsub!(opt_v){
              rpl = ''
              rpl = "#{$1.to_s}#{prms[i]}#{$2.to_s}" if prms[i] && prms[i].strip!=""
            }
          elsif def_v =~ @new #;p $1
            @new.gsub!($~.to_s,(prms[i] && prms[i].strip!="" ? prms[i] : $1)) 
          end
          if eva_v=~ @new
            src =  $~.to_s
            rpl =  prms[i] ? prms[i].send($1).to_s : ""
            @new.gsub!(src,rpl)
          end
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
      p "End2 : #{rpls.strip}" if @dbg[:parse] && rpls!= ''
      rpls
    end
    
    def shortcut_exec(regex)
      if(regex =~ @row;@rgx = $~)
        srcs = @rgx.to_s
        rplc = "#{@rgx[1]}%!_#{@rgx[2]}~#{@rgx[3]}\n"
        @row.gsub!(srcs,rplc)
        p "reExe_ #{@row}." if @dbg[:parse]
      end
    end
    
    def shortcut_equal(regex)
      if(regex =~ @row;@rgx = $~)
        srcs = @rgx.to_s
        rplc = "#{@rgx[1]}%!=~#{@rgx[3]}\n"
        @row.gsub!(srcs,rplc)
        p "reEqu_ #{rplc}" if @dbg[:parse]
      end
    end
    
    #simple tags replacement with mark on the left with <space or tab>@ and 
    #at the end #mark with space or \n ex: @div<space>  or @div<\n>
    #if tag div fine in hot, tags it become a function, but if not 
    #it become w2tags
    def get_hot_simple(regex)
      if(regex =~ @row;@rgx = $~)
        keys = @rgx[2].strip
        opts = @rgx[3]
        opts = $1 << opts if keys.gsub!(/(\/)$/,'')
        hots = keys.gsub(/\{[^\}]*\}$/,'').gsub(/[:#.][\w\-#.=]*$/,'')
        rplc = @tg_hot[hots]!=nil ? 
        "%!#{keys}~#{opts}" : 
        "%!#{keys}!#{opts}" 
        #p @row,ends,rplc
        @row.gsub!(@rgx.captures.join,rplc)
        p "reHot> #{rplc} >> #{hots}" if @dbg[:parse]
      end
    end
    
    #translation for tags with shortcut of name, id, or class and put in constants
    #ex: @div:name#id.class
    #will result in some of this var:
    # @mem_var['$:'     ]
    # @mem_var['$#'     ]
    # @mem_var['$.'     ]
    # @mem_var['%all%'  ]
    # @mem_var['%opt%'  ]
    # @mem_var['%id%'   ]
    # @mem_var['%name%' ]
    # @mem_var['%class%']
    # this var will be use in tranlation in w2tags and translation in hot
    def idclass_var(keys,rgx)
      @mem_var['$:'     ]= ''
      @mem_var['$#'     ]= ''
      @mem_var['$.'     ]= ''
      @mem_var['%all%'  ]= ''
      @mem_var['%opt%'  ]= ''
      @mem_var['%id%'   ]= ''
      @mem_var['%name%' ]= ''
      @mem_var['%class%']= ''
      @mem_var['%code%' ]= ''
      #p keys
      if keys.gsub!(rgx,'')
        keys = $1+$2
        if keys.gsub!(/^:([\w\-]+)/,'')
          @mem_var['$:'     ] = $1.to_s
          @mem_var['%name%' ] = "name=\"#{$1}\" " 
          @mem_var['%all%'  ]<< "name=\"#{$1}\" " 
          @mem_var['%opt%'  ]<< ":#{$1}"
        end
        if keys.gsub!(/^#([\w\-]+)/,'')
          @mem_var['$#'     ] = $1.to_s
          @mem_var['%id%'   ] = "id=\"#{$1}\" " 
          @mem_var['%all%'  ]<< "id=\"#{$1}\" " 
          @mem_var['%opt%'  ]<< "##{$1}"
        end
        if keys.gsub!(/^\.([\w\-.]+)/,'')
          prm = $1
          cls = prm.split('.').collect {|x|x.strip}.join(' ')
          @mem_var['$.'     ] = $1.to_s
          @mem_var['%class%'] = "class=\"#{cls}\" "
          @mem_var['%all%'  ]<< "class=\"#{cls}\" "
          @mem_var['%opt%'  ]<< ".#{prm}"
        end
        if keys.gsub!(/==$/,'')
          @mem_var['%code%' ] = '<%= "$*" %>'
        elsif keys.gsub!(/=$/,'')
          @mem_var['%code%' ] = "<%= $* %>"
        end
        p "const_#{@mem_var["%all%"]}" if @dbg[:constanta]
      end
    end
    
    def parse_hot  
      eva = ''
      col = @row.split('%')
      return false if col.size==1
      (col.size-1).downto(0) do |c|
        eva = "%#{col[c]}" << eva
        @rg_ht.each do |ht|
          if(ht =~ eva;@rgx = $~)
            keys = @rgx[2]
            prms = @rgx[3]
            ends = @rgx[4].to_s.strip      
            idclass_var(keys,/([:#.])([\t\w\-#.= ]*$)/)
            if /^\!/ =~ keys
              @new = (multi_end2(nil)+@spc+@rgx.to_s.gsub('%!','%')).split("\n")
              swap_last_empt_src_with_end_tg(@new)
              @row = ''
            else
              @mem_var["&tag!"] = keys

              if @tg_hot[keys]
                hots = @tg_hot[keys]      
                @new = hots[0].call(self).clone  
                
                if @new.strip=="" #&& @tg_end[-1]
                  @tg_end << "#{@spc}#{hots[1][0]}"
                  empt = @row.gsub!(@rgx.to_s,"").strip
                  @row = empt if empt == ""  #remove if empty (only \t,\n)
                else
                  @tg_end << "#{@spc}#{hots[1]}" if hots[1]
                  @new.gsub!(/\n/,"\n#{@spc}")
                  get_dollar(prms,hots[1])
                  @new+= ends if ends!=''    #;p "NEW:::#{@new}"
                  @doc_src = @row.gsub(@rgx.to_s,@new).split("\n")+@doc_src
                  @row = @doc_src.shift+"\n"
                  parse_spc
                end
                p "Func>> #{@new}" if @dbg[:parse]
              else
                @row.gsub!(@rgx.to_s,"<!-- no hot for:#{keys} -->")
              end
            end
            break
          end
        end
        break if @rgx
      end
      @rgx!=nil
    end
    
    def get_div(regex)
      if(regex =~ @row;@rgx = $~)
        src = @rgx.captures.join
        keys= @rgx[1,2].join.strip
        opts= @rgx[3].to_s
        opts= $1 << opts if keys.gsub!(/(\/)$/,'')
        tgt = "%!div#{keys}!#{opts}"
        @row.gsub!(src,tgt)
        p "toDiv_ #{tgt}" if @dbg[:parse]
      end
    end
    
    def inside_rmk(regex)
      if(regex =~ @row;@rgx = $~)
        @rmk = @spc.size
        @plt = 99
      elsif @spc.size <= @rmk 
        @rmk = 99 
      end
      @rmk  != 99
    end
    
    def inside_plain_text(regex)
      @rgx = nil
      if(regex =~ @row;@rgx = $~)
        @plt = @spc.size
      elsif @spc.size <= @plt 
        @plt = 99
      end
      @plt  != 99
    end
    
    def parse_all
      if @row.strip == ''
      elsif /(^[\t ]*)(\\)([^\n]*\n)/ =~ @row #escape for plain text "\- "
        @row = $1+$3
      elsif inside_rmk(       /(^[\t ]*)(-#)([^\n]*)\n/) 
        @row = ''
      elsif inside_plain_text(/(^[\t ]*)(-!)([^\n]*\n)/) 
        @row = '' if @rgx
      else
        rtn = true if shortcut_exec( /(^[\t ]*)-([\w\-\/:#.%=]*) ([^\n]+)\n/) 
        rtn = true if shortcut_equal(/(^[\t ]*)=([\w\-\/:#.%=]*) ([^\n]+)\n/) 
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w:#.=]+\{[^\}]*\}[#.=]?[^! ]* )([^\n]*)\n/)
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w:#.=]+\{[^\}]*\}[#.=]?[^! ]*)()\n/)
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w\-\/:#.%=]+ )([^\n]*)\n/) 
        rtn = true if get_hot_simple(/^[\t ]*(%)([\$\w\-\/:#.%=]+)()\n/) 
        rtn = true if get_div(/^[\t ]*([#.=])([\w:#.=]+\{[^\}]*\}[#.=]?[^ ]* )([^\n]*)\n/)
        rtn = true if get_div(/^[\t ]*([#.=])([\w:#.=]+\{[^\}]*\}[#.=]?[^ ]*)()\n/)
        rtn = true if get_div(/^[\t ]*([#.=])([\w\-.=\/]+ )([^\n]*)\n/) 
        rtn = true if get_div(/^[\t ]*([#.=])([\w\-.=\/]+)()\n/) 
        rtn = true if parse_hot
        rtn = true if merge_hot
        rtn = true if merge_w2x
        rtn = true if parse_set_var
        rtn = true if parse_set_mem
        rtn = true if parse_tags
        rtn = true if parse_get_mem
        rtn = true if parse_end
      end
      rtn
    end
    
    def parse_set_mem
      @mem_tag["^"]= $2 if @row.gsub!(/([ \t]*~\^)([^`\n]+)(`|\n)/,'')
    end
    
    def get_mem(regex)
      if(regex =~ @row;@rgx = $~)
        keys,tmp,prms,opt,ends= @rgx.captures
        if opt=='!'
          opt=''
          @mem_hot=nil
        end
        @new = @mem_tag[keys].clone
        get_dollar(prms)
        p "exPand #{@new.strip}" if @dbg[:parse]
        @row.gsub!(@rgx.to_s,@new+opt+ends)
        #p "exPand "+@row.strip if @dbg[:parse]
        rows = @row.split("\n")     
        if rows.size>1
            @doc_src = rows+@doc_src
            @row = @doc_src.shift+"\n"
        end
      end
      @rgx!=nil
    end
    
    def parse_get_mem
      get_mem(/([\^])()\{([^\}]*)\}([^`\n]*)(`|\n)/) ? true : \
      get_mem(/([\^])()([^`\n]*)(`|\n)/)
    end
    
    def get_end(regex)
      if(regex =~ @row;@rgx = $~)
        if @rgx[1]=='.'
          @new = multi_end(1)
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
    
    def parse_end
      (get_end(/^(,)\/(`|\n)/ ) ? true : \
      (get_end(/(\.+)\/(`|\n)/) ? true : \
       get_end(/^[ \t]*(!)\/(`|\n)/)))
    end
    
    def parse_tags
      @rgx = nil
      par  = []
      rgs  = @rg_tg.collect {|r|par << (r =~ @row);$~}
      if (max = par.compact.sort.pop)      #have any to parse?
        @rgx= rgs[par.index(max)]
      
        srcs = @rgx.to_s
        pops = @rgx.captures.pop
        @key = @rgx[2].strip.gsub(/\{([^\}]*)\}/,'') 
        @att = $1.to_s.strip
        @txt = @rgx[3]
        idclass_var(@key,/([:#.=])([\t\w\-#.= ]*$)/)
        
        if /^\!/ =~ @key
          @row = ''
          @new = (multi_end(nil)+@spc+@rgx.to_s.gsub('%!','%')).split("\n")
          swap_last_empt_src_with_end_tg(@new)
        else
          tag_next = @tg_nex[@key] #;p "%mem_hot:#{@mem_hot}:#{@key}"
          tag_next[1].call if tag_next && @mem_hot==nil
          rplc = @tagr.call(self) 
          rplc<< pops if pops != '`'
          @mem_var.each do |k,v|
            rplc.gsub!(k,v)
          end
          @row.gsub!(srcs,rplc)
          p "W2Tag: #{srcs}" if @dbg[:parse]
        end
      end  
      @rgx!=nil
    end
  end  
end
