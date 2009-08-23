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
          W2TAGS.parse_file(src,true,true)
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
        if Sinatra::VERSION > '0.9.1'
          def lookup_template(engine, template, views_dir, filename = nil, line = nil)
            case template
            when Symbol
              if cached = self.class.templates[template]
                lookup_template(engine, cached[:template], views_dir, cached[:filename], cached[:line])
              else
                path = ::File.join(views_dir, "#{template}.#{engine}")
                src = path.gsub(path[/(\.\w+)$/,1],'.w2'<<$1[1,9])
                W2TAGS.parse_file(src,true,true)
                [ ::File.read(path), path, 1 ]
              end
            when Proc
              filename, line = self.class.caller_locations.first if filename.nil?
              [ template.call, filename, line.to_i ]
            when String
              filename, line = self.class.caller_locations.first if filename.nil?
              [ template, filename, line.to_i ]
            else
              raise ArgumentError
            end
          end
        else
          def lookup_template(engine, template, options={})
            case template
            when Symbol
              path= template_path(engine, template, options)
              src = path.gsub(path[/(\.\w+)$/,1],'.w2'<<$1[1,9])
              W2TAGS.parse_file(src,true,true)
            end
            super
          end
        end
      end
      
      class Base
        include W2TagsHooked
      end
    end
  end
end
