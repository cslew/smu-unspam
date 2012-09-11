require 'dm-chunked_query'
require 'haml'
require 'sinatra'
require_relative File.join('config', "shared.rb")

get '/' do
  mails = paginate(SmuEmail.all(order: [:date.desc]), params[:page], 2)

  if mails.length == 0
    params[:page] = 1
    mails = paginate(SmuEmail.all(order: [:date.desc]), params[:page], 2)
  end

  haml :index, :locals => { :env => ENV["RACK_ENV"], :mails => mails, :page_count => @page_count,
                            :current_page => params[:page].to_i }
end

def paginate(query, page, per_page)
  @page = (page || 1).to_i
  @per_page = (per_page || 10).to_i

  @pages = query.chunks_of(per_page)
  @total_count = @pages.count
  @page_count = @pages.length

  @pages[@page - 1]
end
