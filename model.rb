def valid_user()
    if session[:user_id] == nil
      redirect('/')
    end
end

def db
    database = SQLite3::Database.new("db/slpws23_toiletreviews.db")
    database.results_as_hash = true
    return database
end

def register_user(username, password)
    password_digest = BCrypt::Password.create(password)
    db.execute('INSERT INTO users (name,password_digest,role ) values (?,?,"user")', username, password_digest)
end

def login_user(username, password)
    result = db.execute("SELECT user_id, password_digest FROM users WHERE name = ?", username)
    if result.empty?
      return false
    end
    user_id = result.first["user_id"]
    password_digest = result.first["password_digest"]
    if BCrypt::Password.new(password_digest) != password
        return false
    end
    return user_id
end

def get_toilets()
    toilets = db.execute("SELECT * FROM toilets")
    relations = db.execute("SELECT * FROM ((attribute_toilet_relation INNER JOIN toilets ON attribute_toilet_relation.toilet_id = toilets.toilet_id) INNER JOIN attributes ON attribute_toilet_relation.attibute_id = attributes.attribute_id)")
    toilet_attributes = Hash.new([])
    for relation in relations
        if !toilet_attributes.has_key?(relation["name"])
            toilet_attributes[relation["name"]]=[]
        end
        toilet_attributes[relation["name"]].append(relation["type"])
    end
    return [toilets, toilet_attributes]
end

def new_toilet(new_toilet)
    db.execute("INSERT INTO toilets (name) VALUES (?)",new_toilet)
end

def get_toilet_by_id(id)
    posts = db.execute("SELECT * FROM posts INNER JOIN users ON posts.user_id = users.user_id WHERE toilet_id=?", id)
    toilet = db.execute("SELECT name FROM toilets WHERE toilet_id=?", id).first
    return[posts, toilet]
end

def new_post(text, rating, id, user_id)
    db.execute("INSERT INTO posts (text, rating, toilet_id, user_id) VALUES (?, ?, ?, ?)", text, rating, id, user_id)
end

def delete_post(post_id)
    db.execute("DELETE FROM posts WHERE post_id = ?", post_id)
end

def update_post(new_text, new_rating, post_id)
    if params[:new_text] != ""
        db.execute("UPDATE posts SET text = ?, rating = ? WHERE post_id = ?",new_text, new_rating, post_id)
      else
        db.execute("UPDATE posts SET rating = ? WHERE post_id = ?", new_rating, post_id)
      end
end