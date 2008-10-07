module ActionView
	module TemplateHandlers
		if	Object::RAILS_ENV != "development" 
			puts 'W2Tags Only RUN on (RAILS_ENV == "development")'
		else
			puts 'W2Tags Hooked on Rails!'
			module W2TagsHooked
				W2TAGS = W2Tags::Parser.new
				def compile_template(template) #not private(super call)
					src = template.filename.gsub(/\.erb$/,'.w2erb')
					W2TAGS.parse_file(src,false,true)
					super 
				end
			end
			class ERB < TemplateHandler
				include W2TagsHooked
			end
		end
	end
end
