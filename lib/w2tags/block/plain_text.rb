module W2Tags 
  module Block
    module PlainText
      #when command is "-!", it means that inside these
      #indentation will not be parsed.
      # Example:
      # %head
      #  %script
      #   -!
      #    $(function(){
      #      alert('Hello World');
      #    });
      def plain_text_skip_initialize()
        @plt_opt= '' #plaintext option
        @doc_plt= [] #plaintext buffer
        @plt    = 99 #plaintext indentation
      end
      
      def plain_text_skip
        @rgx = nil
        @plt_opt = ''
        if(/(^[\t ]*)(-!+[ ]?)([^\n]*)\n/ =~ @row;@rgx = $~)
          @row = ''
          @plt = @spc.size
          @plt_opt = @rgx[2]
          @doc_plt = []
          if @rgx[3].strip != "" 
            if @plt_opt[1,2]=='!!'
              @doc_plt << " #{@rgx[3].strip}\n" 
            else
              @doc_plt << "#{@spc} #{@rgx[3].strip}\n" 
            end
          end
        elsif @plt != 99 
          if @spc.size<= @plt && @ron!=0
            @doc_out   = @doc_out + @doc_plt
            @plt = 99
          else
            plain_text_parser
          end
        end
        @plt!=99
      end
      
      private
      
      def plain_text_parser
        if @plt_opt[1,2]=='!!'
          @doc_plt << @row[@plt,999].rstrip<<"\n"
        else
          @doc_plt << @row.rstrip<<"\n"
        end
        @row = '' 
      end
    end
  end
end
