require 'haml'
require 'sinatra'
require_relative File.join('config', "shared.rb")

get '/' do
  mails = SmuEmail.all(order: [:date.desc])
  haml :index, :locals => { :env => ENV["RACK_ENV"], :mails => mails }
end
