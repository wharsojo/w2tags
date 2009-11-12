require 'sinatra'
#require 'w2tags/sinatra_hook'

W2 = W2Tags::Parser.new('rails')

get '/' do
  erb :index
end

post '/parse' do
  @result= W2.parse_line("%initialize\n"<<params[:input]).join('')
  erb :parse, :layout => false
end

