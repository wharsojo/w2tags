module W2Tags 
  module Block
      module Remark
      #when command is "-#", it means that inside these
      #indentation will not include on the result or it
      #become some comment.
      # Example:
      # -#
      #  THIS COMMENT 
      #  WILL NOT SHOW ON RESULT
      def remark_skip_initialize
        @rmk    =  99    #remark indentation
      end
      
      def empty_skip
        @row.strip == ''
      end
      
      def line_skip
        if /(^[\t ]*)(\\)([^\n]*\n)/ =~ @row #escape for plain text "\- "
          @row = $1+$3
        end
      end
      
      def remark_skip
        if(/(^[\t ]*)(-#)([^\n]*)\n/ =~ @row;@rgx = $~)
          @rmk = @spc.size #@plt = 99
        elsif @rmk !=99
          @rmk = 99 if @spc.size <= @rmk && @ron!=0
          #p "remrk> #{@rgx[3].strip}" if @dbg[:parse]
        end
        @row = '' if @rmk!=99
        @rmk!=99
      end
    end
  end
end
