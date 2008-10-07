module Merb::Template
	if Merb.environment != "development"
		puts 'W2Tags Only RUN on (Merb.environment == "development")'
	else
		puts 'W2Tags Hooked on Merb!'
		W2TAGS = W2Tags::Parser.new
		class << self
			def load_template_io(path)
				src = path.gsub(/\.erb$/,'.w2erb')
				W2TAGS.parse_file(src,false,true)
				File.open(path)
			end
		end
	end
end
