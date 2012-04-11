module ActionView
  if	Object::RAILS_ENV != "development"  
    puts 'W2Tags Only RUN on (RAILS_ENV == "development")'
  else
    puts 'W2Tags Hooked on Rails 3.x !'
    class PathResolver
      W2TAGS = W2Tags::Parser.new('rails')
      def query(path, exts, formats)
        query = File.join(@path, path)

        exts.each do |ext|
          query << '{' << ext.map {|e| e && ".#{e}" }.join(',') << ',}'
        end

        query.gsub!(/\{\.html,/, "{.html,.text.html,")
        query.gsub!(/\{\.text,/, "{.text,.text.plain,")

        Dir[query].reject { |p| File.directory?(p) }.map do |p|
          handler, format = extract_handler_and_format(p, formats)
          W2TAGS.parse_file(p.gsub(/\.erb$/,'.w2erb'),true,true)
          contents = File.open(p, "rb") {|io| io.read }

          Template.new(contents, File.expand_path(p), handler,
            :virtual_path => path, :format => format)
        end
      end
    end
  end  
end