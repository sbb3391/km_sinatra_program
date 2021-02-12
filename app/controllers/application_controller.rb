require 'pry'
require_relative '../../config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  get '/model/:id' do 
    @model = Model.all.find(self.params[:id])
   

    erb :'index.html'
  end

  post '/model' do

  end
  
  get '/' do
    @models = Model.all
    @accounts = Account.all

    erb :'index.html'

  end

  post '/' do
    puts "There were #{Proposal.all.count} proposals."
    Proposal.create(account_id: Account.find(params[:account_id]).id)


    params.each do |k,v|
      if v == "on"
        Proposal.all.last.units.create(model_id: k.to_i)
      end
    end
    puts "Now there are #{Proposal.all.count} proposals."

    redirect to "proposals/#{Proposal.all.last.id}"
  end

  get '/proposals/:id/edit' do
    @proposal = Proposal.find(params[:id])

    erb :'edit_proposal.html'
  end

  get '/proposals/:id' do 
    @proposal = Proposal.find(params[:id])

    erb :'show_proposal.html'
  end


  post '/articlesparams' do
    binding.pry

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

  delete "/articles/:id" do 
    article = Article.find(params[:id])
    article.destroy

    redirect to "/articles"
    
  end


end
