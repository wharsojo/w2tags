require 'hpricot'

class Tags2w

  def initialize
    @cod_if = false
    @doc_out= []
    @level  = 0
    @line   = ''
    @tags   = %w[h1]
  end
  
  def start(el)
    initialize
    sub_element(el) 
  end
  
  def result
    @doc_out
  end
  
  def element(el) 
    if el.class==Hpricot::Text
      tag= el.name
    elsif el.class==Hpricot::Comment
      tag= "<!--#{el.name}-->"
    else
      #p el.html
      at = el.respond_to?(:attributes) ? el.attributes : {}
      tag= "%#{el.name}"
      if at['name']
        tag<<":#{at['name']}" 
        at.delete 'name'
      end
      if at['id']
        tag<<"##{at['id']}" 
        at.delete 'id'
      end
      if at['class']
        tag<<".#{at['class'].split(' ').join('.')}" 
        at.delete 'class'
      end
      if at.length>0
        ex= at.collect{|k,v|[k,'="',v,'"'].join}.join(' ')
        tag<<"{#{ex}}"
      end
      if /\%div([#.])/ =~ tag
        tag.gsub!(/\%div([#.])/,$1) 
      else
        tag.gsub!(/\%input\:/,':') 
      end
      if /\%cmd\./ =~ tag
        #puts tag
        tag.gsub!(/\%cmd\.if\{(.*?)\}/    ,    "-if #{$1}") if /\%cmd\.if\{att="(.*?)"\}/    =~ tag
        tag.gsub!(/\%cmd\.for\{(.*?)\}/   ,   "-for #{$1}") if /\%cmd\.for\{att="(.*?)"\}/   =~ tag
        tag.gsub!(/\%cmd\.unless\{(.*?)\}/,"-unless #{$1}") if /\%cmd\.unless\{att="(.*?)"\}/=~ tag
        tag.gsub!(/\%cmd\.elsif\{(.*?)\}/ , "-elsif #{$1}") if /\%cmd\.elsif\{att="(.*?)"\}/ =~ tag
        tag.gsub!(/\%cmd\.else\{(.*?)\}/  ,  "-else #{$1}") if /\%cmd\.else\{att="(.*?)"\}/  =~ tag
        tag.gsub!(/\%cmd\.each\{(.*?)\}/  ,  "-each #{$1}") if /\%cmd\.each\{att="(.*?)"\}/  =~ tag
        tag.gsub!(/\%cmd\.each2\{(.*?)\}/ , "-each2 #{$1}") if /\%cmd\.each2\{att="(.*?)"\}/ =~ tag
        tag.gsub!(/\%cmd\.form_tag\{(.*?)\}/,"-form_tag #{$1}") if /\%cmd\.form_tag\{att="(.*?)"\}/=~ tag
        tag.gsub!(/\%cmd\.form_for\{(.*?)\}/,"-form_for #{$1}") if /\%cmd\.form_for\{att="(.*?)"\}/=~ tag
      else  
        tag.gsub!(/\%\<\?xml/             ,        "<?xml") if /^\%\<\?xml/                  =~ tag
        tag.gsub!(/\%\<\!DOCTYPE/         ,    "<!DOCTYPE") if /^\%\<\!DOCTYPE/              =~ tag
      end                                                
    end
    tag  
  end

  def equal(line)
    rtn = []
    line.split("\n").each do |ln|
      if /\<%=(.*)[-]?%\>/=~ ln
        rtn<< ('= '<< $1.lstrip.gsub(/\-$/,'') )
      else
        rtn<< (' ' << ln.rstrip)
      end
    end
    rtn.join("\n")
  end
  
  def ruby_equal(el)
    rtn = equal(element(el).strip).gsub(/ *\%w2code_equ/,'=') 
    ch= el.respond_to?(:children) ? el.children : nil
    if ch && ch.length==1
      rtn<< ruby_equal(el.children[0])
    end
    rtn
  end
  
  def in_block(blk)
    spc1= '  '*(@level)
    spc2= '  '*(@level+1)
    [spc1,blk.gsub(/\n +/,"\n#{spc2}")].join
  end
  
  def in_block2(blk)
    les= 999
    spc= '  '*(@level+1)
    #blk= ['  ',blk].join
    lns= blk.split("\n")
    lns.each do |l|
      x=(/ */=~l)
      les=x if x<les
    end
    lns.collect {|l|[spc,l[les,999]].join}.join("\n").sub(/^  /,'')
  end

  def sub_element(parent)
    if parent.children
      parent.children.each do |el|
        @line= element(el).strip
        if @line!=''
          if el.class==Hpricot::Comment
            @doc_out << ['  '*(@level),@line].join 
          elsif el.class==Hpricot::Text
            @doc_out << ['  '*(@level),@line].join 
          else
            if el.name=='script'
              @doc_out << in_block2(@line << el.html)
            elsif el.name=='w2comment'
              @doc_out << in_block2("%comment"<< el.html)
            elsif el.name=='w2code_equ'
              @doc_out << in_block2("="<< el.html)
            else
              ch= el.respond_to?(:children) ? el.children : nil
              if @line[0,1]!='-' && ch && ch.length==1
                  inline= ruby_equal(el.children[0]) 
                  inline= " (#{inline.lstrip}%)" if /\%\w/ =~ inline
                  @doc_out << ['  '*@level,@line,inline].join 
              else
                if /\%cmd/ !~ @line
                  rtn= ['  '*@level,@line].join 
                  rtn.gsub!('<w2code_equ>','<%=')
                  rtn.gsub!('</w2code_equ>','%>')
                  @doc_out << rtn
                  if ch
                    @level+=1
                    sub_element(el) 
                    @level-=1
                  end
                end
              end
            end
          end
        end
      end
    end
    self
  end
   
  def line_code
    @doc_med= []
    @doc_out.join("\n").split("\n").each_with_index do |ln,i|
      doc= ''
      if /[^"] *\<%(=.*)[-]?%\>/=~ ln
        ln.gsub!(/[^"] *\<%=.*[-]?%\>/,$1.lstrip.gsub(/\-$/,'')) 
        @doc_med<< ln
      elsif /[^"] *\<%(.*)[-]?%\>/ =~ ln
        code= $1.lstrip.gsub(/\-$/,'')
        part= code.split(/ +/)[0]
        if %w[if elsif else].find_index(part)
          @cod_if = true
          code= "-#{code}" 
        else
          code= "- #{code}" 
        end
        if @cod_if && (%w[end].find_index(part))
          @cod_if= false
        else
          ln.gsub!(/\<%.*[-]?%\>/,code) 
          @doc_med<< ln 
        end
      else
        @doc_med<< ln
      end
    end
    @doc_out= @doc_med
  end
  
  
end

class MakeTag

  def make_it(lines)
    @lvl_dp= 0
    @blk_ar= Array.new(20,[''])  #level, space
    lines.each_with_index do |l,i|
      dbg=''
      if /( *)\<% *(\w+)[(]?(.*?)[)]? *do *\|(.*?)\|/ =~ l
        @lvl_dp += 1
        blk= ["<cmd class=\"#{$2}\" att=\"#{$3};#{$4}\">","<form_for>"]
        dbg<< "#{$1}#{blk[0]}"
        @blk_ar[@lvl_dp]= blk
      elsif /( *)\<% *(\w+)[(]?(.*?)[)]? *do */ =~ l
        @lvl_dp += 1
        blk= ["<cmd class=\"#{$2}\" att=\"#{$3}\">","<form_tag>"]
        dbg<< "#{$1}#{blk[0]}"
        @blk_ar[@lvl_dp]= blk
      elsif /( *)\<% *(.*? ) *do *\|(.*?)\|/ =~ l
        spc= $1
        cmd= $2
        att= $3
        #cmd=$2.split('.')[0]
        att= $3.lstrip.gsub(/\-$/,'')
        if cmd.gsub!(/.each /,'')
          blk= ["<cmd class=\"each\" att=\"#{cmd};#{att}\">" ,'<each>']  
        elsif cmd.gsub!(/.each_with_index /,'')
          blk= ["<cmd class=\"each2\" att=\"#{cmd};#{att}\">",'<each2>'] 
        else
          blk= ["<cmd class=\"#{cmd}\" att=\"#{att}\">","<#{cmd}>"]
        end
        @lvl_dp += 1
        @blk_ar[@lvl_dp]= blk
        dbg<< "#{spc}#{blk[0]}"
      elsif /( *)\<% *([\w_]+) *(.*?)%>/ =~ l
        spc= $1
        cmd= $2
        att= $3.lstrip.gsub(/\-$/,'')
        if %w[unless if for].find_index(cmd)
          @lvl_dp += 1
          blk= ["<cmd class=\"#{cmd}\" att=\"#{att}\">","<#{cmd}>"]
          dbg<< "#{spc}#{blk[0]}"
          @blk_ar[@lvl_dp]= blk
        elsif %w[elsif else].find_index(cmd)
          blk= ["</cmd><cmd class=\"#{cmd}\" att=\"#{att}\">","<#{cmd}>"]
          dbg<< "#{spc}#{blk[0]}"
          @blk_ar[@lvl_dp]= blk
        elsif %w[end].find_index(cmd)
          blk= ["</cmd>"]  
          dbg<< "#{spc}#{blk[0]}"
          @lvl_dp -= 1
        end
      elsif /( *)\<%=(.*?)%>/ =~ l
        while /( *)\<%=(.*?)%>/ =~ l do 
          l= l.sub(/( *)\<%=(.*?)%>/,"#{spc}<w2code_equ>#{$2}</w2code_equ>")
        end
        dbg<< l 
      elsif /( *)\<\!\-\-(.*)\-\-\>/ =~ l
        dbg<< "#{spc}<w2comment>#{$2}</w2comment>"
      elsif /( *)\<\!\-\-(.*)/ =~ l
        @lvl_dp += 1
        blk= ["<w2comment>#{$2}",'<comment>']
        @blk_ar[@lvl_dp]= blk
        dbg<< "#{spc}#{blk[0]}"
      elsif /(.*)\-\-\>/ =~ l
        blk= ["#{$1}</w2comment>"]  
        dbg<< "#{spc}#{blk[0]}"
        @lvl_dp -= 1
      end
      if dbg!=''
        #puts dbg 
        lines[i]= dbg
      end
    end
  end
end
