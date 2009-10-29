require 'sinatra'

W2 = W2Tags::Parser.new('rails')

get '/' do
  erb :index
end

post '/' do
  @result= W2.parse_line("%initialize\n"<<params[:input]).join('')
  erb :index
end
