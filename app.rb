require 'sinatra/base'
require './lib/user'
require './lib/database'
require './lib/helpers'
require './lib/peeps'
require './lib/mailer'

class ChitterApp < Sinatra::Base
  enable :sessions

  get '/' do
    redirect '/posts'
  end

  get '/register' do
    erb :signup
  end

  post '/register' do
    User.save(params[:username], params[:email], params[:password])
    redirect '/log_in'
  end

  get '/log_in' do
    erb :log_in
  end

  post '/log_in' do
    session[:user_id] = LoginHelper.verify_log_in(params)
    redirect '/posts'
  end

  get '/posts' do
    @user = User.create(session[:user_id])
    @peeps = Peeps.all
    erb :show_posts
  end

  post '/posts' do
    @user = User.create(session[:user_id])
    Peeps.save(params[:content], @user.id)
    @tagged = MailHelper.tagged_user(params[:tag])
    Mailer.notification(@tagged).deliver_now if @tagged
    redirect '/posts'
  end

  get '/log_out' do
    session[:user_id] = false
    redirect '/posts'
  end

  get '/posts/new' do
    @logged_in = session[:user_id]
    erb :post_form
  end
end
