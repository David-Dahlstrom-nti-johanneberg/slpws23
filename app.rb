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
    if !user_id
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
  toilets, toilet_attributes, all_attributes = get_toilets_and_attributes()
  slim(:'toilets/index', locals:{toilets:toilets, toilet_attributes:toilet_attributes, all_attributes:all_attributes})
end

post('/toilets/add') do
  valid_user(session[:user_id])
  new_toilet(params[:toilet])
  add_attributes_to_toilet(params[:toilet])
  redirect('/toilets')
end

get('/toilets/:id') do
  id = params[:id]
  posts, toilet = get_toilet_by_id(id)
  if toilet == nil
    return 404
  end
  slim(:'toilets/show', locals:{posts:posts, id:id, toilet:toilet})
end

post('/toilets/:id/add') do
  valid_user(session[:user_id])
  id = params[:id]
  new_post(params[:text], params[:rating].to_i, id, session[:user_id])
  redirect("/toilets/#{id}")
end

post('/toilets/:id/:post_id/update')do
  valid_user(session[:user_id])
  update_post(params[:new_text], params[:new_rating].to_i, params[:post_id])
  redirect("/toilets/#{params[:id]}")
end

post('/toilets/:id/:post_id/delete')do
  valid_user(session[:user_id])
  delete_post(params[:post_id])
  redirect("/toilets/#{params[:id]}")
end