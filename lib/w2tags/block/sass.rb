module W2Tags 
  module Block
    module Sass
      def sass_skip_initialize
        @doc_sas= [] #sass buffer
        @key_sas= [] #sass indentation
        @nms_sas= [0,""]
        @sas    = 99 #sass indentation block
      end
      
      def sass_skip
        @rgx = nil
        if(/(^[\t ]*)(~~~)\n/ =~ @row;@rgx = $~)
          @row = ''
          @sas = @spc.size
          @doc_sas = [[' '*@sas,"<style>\n"].join]
          @key_sas = [] #sass indentation
          @nms_sas = [0,""]
        elsif @sas!= 99 
          if @spc.size<= @sas
            @doc_sas<< "#{' '*@key_sas[-1][0]}}\n"
            @doc_sas<< @doc_sas[0].gsub("<style>","</style>")
            @doc_out = @doc_out + @doc_sas
            @sas = 99
          elsif @row.strip!=''
            sass_parser
          end
        end
        @sas!=99
      end
      
      private
      
      def sass_parser
        spc= @spc.size
        if(/(^[\t ]*)(:[\w\-]+) *\n/ =~ @row;@rgx = $~)
          @nms_sas= [spc,[$1,$2[1,99],"-"].join] 
        elsif(/(^[\t ]*)(:[\w\-]+) +([^\n]+)\n/ =~ @row;@rgx = $~)
          nms= @nms_sas[0]!=0 && @nms_sas[0]<spc ? @nms_sas[1] : $1
          @doc_sas << [nms,$2[1,99],":",$3,";\n"].join
        else
          old_spc= nil
          if @key_sas!=[]
            old_spc  = @key_sas[-1][0] 
            @key_sas = @key_sas.select{|l|l[0]<spc} if spc<= old_spc
          end
          @key_sas<< [spc,@row.strip] 
          @doc_sas<< [' '*old_spc,   "}\n"].join if old_spc 
          @doc_sas<< [@spc,sass_join,"{\n"].join
          @nms_sas = [0,""]
        end
        @row = '' 
      end
      
      def sass_join
        rtn= ''
        @key_sas.each do |line|
          rtn = (rtn==''? [''] : rtn.split(',')).collect do |p|
            line[1].split(',').collect do |x|
              (x.gsub!(/&/,p) ? x : p+' '+ x).strip
            end.join(',')
          end.join(',')
        end
        rtn
      end
    end
  end
end
