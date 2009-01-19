module Sinatra
  if Sinatra::VERSION < '0.9' 
    if Sinatra::Application.default_options[:env] != :development
		  puts 'W2Tags Only RUN on (Sinatra::Application.default_options[:env] == :development)'
		else
      puts 'W2Tags Hooked on Sinatra < 0.9.x!'
      
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
  elsif Sinatra::VERSION > '0.9'
    if Sinatra::Application.environment != :development
		  puts 'W2Tags Only RUN on (Sinatra::Application.environment == :development)'
	  else
      puts 'W2Tags Hooked on Sinatra > 0.9.x!'
      
      module W2TagsHooked
        W2TAGS = W2Tags::Parser.new
        def lookup_template(engine, template, options={})
          case template
          when Symbol
            path = File.join(
              options[:views_directory] || self.options.views,
              "#{template}.#{engine}"
            )
            src = path.gsub(path[/(\.\w+)$/,1],'.w2'<<$1[1,9])
            W2TAGS.parse_file(src,false,true)
          end
          super
        end
      end
      
      class Application
        include W2TagsHooked
      end
    end
  end
end
