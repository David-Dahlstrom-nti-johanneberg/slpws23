require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
enable :session

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
      redirect('/temporary') #DONT FORGET TO CHANGE ME
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

get('/temporary')do
    slim(:temporary)
end