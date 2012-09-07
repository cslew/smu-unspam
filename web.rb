require 'haml'
require 'sinatra'
require_relative File.join('config', "shared.rb")

get '/' do
  mails = SmuEmail.all
  haml :index, :locals => { :env => ENV["RACK_ENV"], :mails => mails }
end
