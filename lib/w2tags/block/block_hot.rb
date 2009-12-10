module W2Tags 
  module Block
    module BlockHot
      def bhot_skip_initialize
        @end_hot= nil
        @key_hot= '' #key for hot
        @doc_hot= [] #bhot buffer
        @bht    = 99 #hot indentation block
      end
      
      def bhot_skip
        @rgx = nil
        if(/(^[\t ]*)(!H!) *(\w+) *\n/ =~ @row;@rgx = $~)
          # if current line was inside in this block 
          # flush as an adding hot and reinit for new hot
          if @bht != 99
             make_hot
          end
          @end_hot= nil
          @key_hot= $3.strip
          @doc_hot= [] #bhot buffer
          @bht = @spc.size
        elsif @bht!= 99 
          if @spc.size<= @bht && @ron!=0
             make_hot
             @bht = 99
          elsif @row.strip!=''
             if /(\<\<\/)(.+)/ =~ @row
               @end_hot= $2
             else
               @doc_hot<< @row
             end
          end
        end
        @row = '' if @bht!=99
        @bht!=99
      end
      
      private
      
      def make_hot
        les= 999
        @doc_hot.each do |l|
          if l.strip!=''
             x=(/[^ ]/=~l)
             les=x if x<les
          end
        end
        ref  =@doc_hot.collect{|l|l[les,999]}.join
        @tg_hot[@key_hot]= [proc {|this|ref}, [@end_hot]]
      end
    end
  end
end
