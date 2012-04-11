module ActionView
  if	Object::RAILS_ENV != "development"  
    puts 'W2Tags Only RUN on (RAILS_ENV == "development")'
  else
    puts 'W2Tags Hooked on Rails 2.3.2 & Up!'
    class ReloadableTemplate < Template			
      W2TAGS = W2Tags::Parser.new('rails')
      def mtime
        src = filename.gsub(/\.erb$/,'.w2erb')
        W2TAGS.parse_file(src,true,true)
        File.mtime(filename)
      end
    end
  end  
end
