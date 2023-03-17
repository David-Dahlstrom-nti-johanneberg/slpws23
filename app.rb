require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative 'model.rb'
enable :sessions

get('/')do
    slim(:login)
end

post('/login') do
    username = params[:username]
    user_id = login_user(username, params[:password])
    if user_id == nil
      redirect('/error')
    end
    session[:username] = username
    session[:user_id] = user_id
    redirect('/toilets')
  end

post('/logout')do
  session.clear
  redirect('/')
end

get('/register')do
    slim(:register)
end

post('/register') do
    register_user(params[:username], params[:password])
    redirect('/')
  end

get('/error')do
    slim(:error)
end 

get('/toilets')do
  valid_user()
  toilets, toilet_attributes = get_toilets()
  slim(:'toilets/index', locals:{toilets:toilets, toilet_attributes:toilet_attributes})
end

post('/toilets/add') do
  new_toilet(params[:toilet])
  redirect('/toilets')
end

get('/toilets/:id') do
  valid_user()
  id = params[:id]
  posts, toilet = get_toilet_by_id(id)
  slim(:'toilets/show', locals:{posts:posts, id:id, toilet:toilet})
end

post('/toilets/:id/add') do
  id = params[:id]
  new_toilet(params[:text], params[:rating].to_i, id, session[:user_id])
  redirect("/toilets/#{id}")
end

post('/toilets/:id/:post_id/update')do
  update_post(params[:new_text], params[:new_rating].to_i, params[:post_id])
  redirect("/toilets/#{params[:id]}")
end

post('/toilets/:id/:post_id/delete')do
  delete_post(params[:post_id])
  redirect("/toilets/#{params[:id]}")
end