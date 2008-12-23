module Sinatra
	if Sinatra::Application.default_options[:env] != :development
		puts 'W2Tags Only RUN on (Sinatra::Application.default_options[:env] == :development)'
	else
    puts 'W2Tags Hooked on Sinatra!'
    module W2TagsHooked
      W2TAGS = W2Tags::Parser.new
      def read_template_file(renderer, template, options, scream = true)
        path = File.join(
          options[:views_directory] || Sinatra.application.options.views,
          "#{template}.#{renderer}"
        )
        src = path.gsub(path[/(\.\w+)$/,1],'.w2'<<$1[1,9])
        W2TAGS.parse_file(src,false,true)
        super 
      end
    end
    class EventContext
      include W2TagsHooked
    end
  end
end