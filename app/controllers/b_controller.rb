class AccountsController < ApplicationController

  get '/accounts' do
    current_user

    erb :'/accounts/index.html'
  end

  get '/accounts/new' do
    current_user

    erb :'/accounts/new.html'
  end

  get '/accounts/:id' do
    current_user

    erb :'/accounts/show.html'
  end

  post '/accounts/new' do
    current_user

    if current_user.accounts.where(name: params[:name]).empty?
      new_account = current_user.accounts.create(params)
    end

    redirect to "/accounts/#{new_account.id}"
  end
end