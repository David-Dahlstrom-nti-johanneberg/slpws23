require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
enable :sessions

db = SQLite3::Database.new("db/slpws23_toiletreviews.db")
db.results_as_hash = true

get('/')do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    result = db.execute("SELECT user_id, password_digest FROM users WHERE name = ?", username)
    if result.empty?
      redirect('/error')
    end
    user_id = result.first["user_id"]
    password_digest =result.first["password_digest"]
    if BCrypt::Password.new(password_digest) == password
      session[:username] = username
      session[:user_id] = user_id
      redirect('/toilets')
    else
      redirect('/error')
    end
  end

get('/register')do
    slim(:register)
end

post('/register') do
    username = params[:username]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db.execute('INSERT INTO users (name,password_digest,role ) values (?,?,"user")', username, password_digest)
    redirect('/')
  end

get('/error')do
    slim(:error)
end 

get('/toilets')do
  valid_user()
  toilets = db.execute("SELECT * FROM toilets")
  slim(:'toilets/index', locals:{toilets:toilets})
end

post('/toilets/add') do
  db.execute("INSERT INTO toilets (name) VALUES (?)",params[:toilet])
  redirect('/toilets')
end

get('/toilets/:id') do
  valid_user()
  id = params[:id]
  posts = db.execute("SELECT * FROM posts WHERE toilet_id=?", id)
  toilet = db.execute("SELECT name FROM toilets WHERE toilet_id=?", id).first
  slim(:'toilets/show', locals:{posts:posts, id:id, toilet:toilet})
end

post('/toilets/:id/add') do
  db.execute("INSERT INTO posts (text, rating, toilet_id, user_id) VALUES(?, ?, ?, ?)",params[:text], params[:rating].to_i, params[:id], session[:user_id])
  redirect("/toilets/#{params[:id]}")
end

def valid_user()
  if session[:user_id] == nil
    redirect('/')
  end
end