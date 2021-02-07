
require_relative '../../config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  get '/articles' do 

    erb :index
  end

  get '/articles/new' do

    erb :new
  end

  get '/articles/:id' do 
    @article = Article.find(params[:id])
    
    erb :show
  end

  get '/articles/:id/edit' do
    @article = Article.find(params[:id])

    erb :edit
  end

  patch '/articles/:id' do 
    id = params[:id]
    Article.find(id).update(title: params[:title], content: params[:content])

    redirect to "/articles/#{id}"
  end

  post '/articles' do
    new_article = Article.create(title: params[:title], content: params[:content])

    redirect to "/articles/#{new_article.id}"
  end


end
