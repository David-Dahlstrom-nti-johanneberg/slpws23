def valid_user(user_id)
    return user_id != nil
end

def db
    database = SQLite3::Database.new("db/slpws23_toiletreviews.db")
    database.results_as_hash = true
    return database
end

def admin_check(user_id)
    if user_id == nil
        return "no"
    end
    return db.execute("SELECT role FROM users WHERE user_id = ?", user_id).first["role"]
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

def get_toilets_and_attributes()
    toilets = db.execute("SELECT * FROM toilets")
    relations = db.execute("SELECT * FROM ((attribute_toilet_relation INNER JOIN toilets ON attribute_toilet_relation.toilet_id = toilets.toilet_id) INNER JOIN attributes ON attribute_toilet_relation.attribute_id = attributes.attribute_id)")
    toilet_attributes = Hash.new([])
    for relation in relations
        if !toilet_attributes.has_key?(relation["name"])
            toilet_attributes[relation["name"]]=[]
        end
        toilet_attributes[relation["name"]].append(relation["type"])
    end
    all_attributes = db.execute("SELECT * FROM attributes")
    return [toilets, toilet_attributes, all_attributes]
end

def new_toilet(new_toilet)
    db.execute("INSERT INTO toilets (name) VALUES (?)",new_toilet)
end

def add_attributes_to_toilet(toilet, attributes)
    id = db.execute("SELECT toilet_id FROM toilets WHERE name = ?", toilet).first
    for attribute in attributes
            db.execute("INSERT INTO attribute_toilet_relation (toilet_id, attribute_id) VALUES (?,?)", id["toilet_id"], attribute.to_i)
    end
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

def get_users()
    return db.execute("SELECT * FROM users")
end

def change_role(id)
    if admin_check(id) != "admin"
        role = "admin"
    else
        role = "user"
    end
        db.execute('UPDATE users SET role = ? WHERE user_id = ?', role, id)
end

def delete_user(id)
    db.execute("DELETE FROM posts WHERE user_id = ?", id)
    db.execute("DELETE FROM users WHERE user_id = ?",id)
end

def get_1_toilet_and_attributes(id)
    toilet = db.execute("SELECT * FROM toilets WHERE toilet_id = ?", id).first
    toilet_attributes = db.execute("SELECT * FROM attribute_toilet_relation INNER JOIN attributes ON attribute_toilet_relation.attribute_id = attributes.attribute_id WHERE toilet_id = ?", id)
    all_attributes = db.execute("SELECT * FROM attributes")
    return [toilet, toilet_attributes, all_attributes]
end

def new_toilet_name(name, id)
    db.execute("UPDATE toilets SET name = ? WHERE toilet_id = ?",name, id)
end

def delete_attribute_from_toilet(id)
    db.execute("DELETE FROM attribute_toilet_relation WHERE attribute_toilet_relation_id = ?", id)
end

def delete_toilet_and_its_posts(id)
    db.execute("DELETE FROM posts WHERE toilet_id = ?", id)
    db.execute("DELETE FROM attribute_toilet_relation WHERE toilet_id = ?", id)
    db.execute("DELETE FROM toilets WHERE toilet_id = ?", id)
end

def add_attribute(type)
    db.execute("INSERT INTO attributes (type) VALUES (?)", type)
end

def delete_attribute(id)
    db.execute("DELETE FROM attribute_toilet_relation WHERE attribute_id = ?", id)
    db.execute("DELETE FROM attributes WHERE attribute_id = ?", id)
end