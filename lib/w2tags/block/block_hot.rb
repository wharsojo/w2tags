module W2Tags 
  module Block
    module BlockHot
      def bhot_skip_initialize
        @key_hot= '' #key for hot 
        @doc_hot= [] #bhot buffer
        @bht    = 99 #hot indentation block
      end
      
      def bhot_skip
        @rgx = nil
        if(/(^[\t ]*)(!H!) *(\w+)\n/ =~ @row;@rgx = $~)
          @key_hot= $3.strip
          @doc_hot= [] #bhot buffer
          @bht = @spc.size
        elsif @bht!= 99 
          if @spc.size<= @bht
            les= 999
            @doc_hot.each do |l|
              if l.strip!=''
                x=(/[^ ]/=~l)
                les=x if x<les
              end
            end
            ref  =@doc_hot.collect{|l|l[les,999]}.join
            @tg_hot[@key_hot]= [proc {|this|ref}, nil]
            @bht = 99
          elsif @row.strip!=''
            @doc_hot<< @row
          end
        end
        @row = '' if @bht!=99
        @bht!=99
      end
    end
  end
end
