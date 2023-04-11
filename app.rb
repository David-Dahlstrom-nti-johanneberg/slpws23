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
  p"-------------------------------"
  p session[:user_id]
  p"----------------------"
  slim(:'toilets/index', locals:{toilets:toilets, toilet_attributes:toilet_attributes, all_attributes:all_attributes})
end

post('/toilets/add') do
  valid_user(session[:user_id])
  new_toilet(params[:toilet])
  toilets, toilet_attributes, all_attributes = get_toilets_and_attributes()
  attributes = all_attributes.map {|attribute| attribute["attribute_id"]}.filter {|id| params.has_key?(id.to_s)}
  add_attributes_to_toilet(params[:toilet], attributes)
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

get('/users')do
  if admin_check(session[:user_id]) != "admin"
    redirect("/toilets")
  end
  users = get_users()
  slim(:'admin_funktions/users/index', locals:{users:users})
end

post('/users/:id/update')do
  if admin_check(session[:user_id]) != "admin"
    redirect("/toilets")
  end
  change_role(params[:id])
  redirect("/users")
end

post('/users/:id/delete')do
  if admin_check(session[:user_id]) != "admin"
    redirect("/toilets")
  end
  delete_user(params[:id])
  redirect("/users")
end

get('/toilets/:id/edit')do
  if admin_check(session[:user_id]) != "admin"
    redirect("/toilets")
  end
  id = params[:id]
  toilet, toilet_attributes, all_attributes = get_1_toilet_and_attributes(id)
  slim(:'toilets/edit', locals:{toilet:toilet, toilet_attributes:toilet_attributes, all_attributes:all_attributes, id:id})
end

post('/toilets/:id/update')do
  if admin_check(session[:user_id]) != "admin"
    redirect("/toilets")
  end
  new_toilet_name(params[:toilet], params[:id])
  toilet, toilet_attributes, all_attributes = get_1_toilet_and_attributes(params[:id])
  attributes = (all_attributes.map {|attribute| attribute["attribute_id"]}.filter {|id| params.has_key?(id.to_s)}) - toilet_attributes
  p"----------------------------"
  p attributes
  p"----------------------------"
  add_attributes_to_toilet(params[:toilet], attributes)
  redirect("/toilets")
end

post('/toilets/:id/attribute_on_toilet/:attribute_toilet_relation_id/delete')do
  if admin_check(session[:user_id]) != "admin"
    redirect("/toilets")
  end
delete_attribute_from_toilet(params[:attribute_toilet_relation_id])
  redirect("/toilets/#{params[:id]}/edit")
end

post('/toilets/:id/delete')do
  if admin_check(session[:user_id]) != "admin"
    redirect("/toilets")
  end
  delete_toilet_and_its_posts(params[:id])
  redirect("toilets")
end

post('/attribute/:id/delete')do
if admin_check(session[:user_id]) != "admin"
  redirect("/toilets")
end
  delete_attribute(params[:id])
  redirect('/toilets')
end

post('/attribute/add')do
if admin_check(session[:user_id]) != "admin"
  redirect("/toilets")
end
  add_attribute(params[:type])
  redirect('/toilets')
end