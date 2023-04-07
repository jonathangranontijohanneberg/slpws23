require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative './model.rb'


enable :sessions

get('/') do
    slim(:home)
end
  
get('/visual_novel/new') do
    slim(:"visual_novel/new")
end

post('/visual_novel/new') do
    name = params[:name]
    redirect("/visual_novel/new") if name == ""

    genre = params[:genre]
    description = params[:description]
    creator = params[:creator]
    attributes = [genre, description, creator]
    attributes.each { |attribute| attribute << "N/A" if attribute == "" }

    db = initiate_database
    genre_id = attribute_id(genre, "genre", db)
    creator_id = attribute_id(creator, "creator", db)
    visual_novel_id = attribute_id(name, "visual_novel", db)


    # each var var = "NA"


    # if name == "" || genre == "" || description == "" || creator == ""
    #     p "one input at least is an empty array"
    # end
    # db.execute("INSERT INTO visual_novel (name, genre_id, text, creator_id) VALUES (?,?,?,?)", name, genre_id, description, creator_id)

    id = id_with_name(db, name)
    if id != []
        id = id[0]["id"]
        update_visual_novel_table(db, name, genre_id, description, creator_id, id)
        update_visual_novel_creator_relation(db, id, creator_id)
    else
        insert_into_table_four_attributes(db, name, genre_id, description, creator_id)
        insert_into_table_two_attributes(db, visual_novel_id, creator_id)
    end

    redirect("/visual_novel")
end

get('/visual_novel') do
    db = initiate_database
    result = select_all_table_attributes(db, "visual_novel")
    result2 = select_all_table_attributes(db, "genre")
    slim(:"visual_novel/index", locals:{visual_novel:result, genre: result2})
end  

get('/visual_novel/:id') do
    id = params[:id].to_i
    db = initiate_database
    result = all_attr_with_same_value(db, "visual_novel", "id", id).first
    result2 = all_attr_with_same_value(db, "genre", "id", result['genre_id']).first
    slim(:"visual_novel/show",locals:{visual_novel: result, genre: result2})
end

post('/visual_novel/:id/delete') do
    id = params[:id].to_i
    db = initiate_database
    delete_table_attributes_with_same_id(db, "visual_novel", "id", id)
    delete_table_attributes_with_same_id(db, "visual_novel_creator_relation", "visual_novel_id", id)
    redirect("/visual_novel")
end


get('/genre') do
    # id = session[:id].to_i
    db = initiate_database
    result = select_all_table_attributes(db, "visual_novel")
    result2 = select_all_table_attributes(db, "genre")
    slim(:"genre/index", locals:{visual_novel: result, genre: result2})
end

get('/genre/:id') do
    genre_id = params[:id].to_i
    db = initiate_database
    result = all_attr_with_same_value(db, "visual_novel", "genre_id", genre_id)
    result2 = all_attr_with_same_value(db, "genre", "id", genre_id).first
    slim(:"genre/show",locals:{visual_novel: result, genre: result2})
end



get('/creator') do
    # id = session[:id].to_i
    db = initiate_database
    result = select_all_table_attributes(db, "visual_novel")
    result2 = select_all_table_attributes(db, "genre")
    result3 = select_all_table_attributes(db, "creator")
    slim(:"creator/index", locals:{visual_novel: result, genre: result2, creator: result3})
end

get('/creator/:id') do
    creator_id = params[:id].to_i
    db = initiate_database
    result = all_attr_with_same_value(db, "visual_novel", "creator_id", creator_id)
    result2 = all_attr_with_same_value(db, "genre", "id", result.first['genre_id'].to_i).first
    result3 = all_attr_with_same_value(db, "creator", "id", creator_id).first

    slim(:"creator/show", locals:{visual_novel: result, genre: result2, creator: result3})
end

get('/register') do
  slim(:register)
end

#######################################################################################################
#######################################################################################################
#######################################################################################################
############################# HÄR SKA DET STÄDAS SEDAN, MASSA SQLITE KOD!!!!!!!########################
#######################################################################################################
#######################################################################################################
#######################################################################################################


get('/user_visual_novel_relation/new') do
  slim(:"user_visual_novel_relation/new")
end

post('/user_visual_novel_relation/new') do
  p "KOMMER TILL NEW RUTTEN #############################################################################"
  user_status = params[:status]
  user_score = params[:score]
  id = params[:id].to_i
  # user_id, vn-id

  user_id = session[:id]

  db = initiate_database
  
  db.execute("INSERT INTO user_visual_novel_relation (user_id, visual_novel_id, user_status, user_score) VALUES (?,?,?,?)", user_id, id, user_status, user_score)
  redirect("/user_visual_novel_relation/new")
end

post('/user_visual_novel_relation') do
  user_status = params[:status]
  user_score = params[:score]
  user_id = session[:id].to_i
  db = SQLite3::Database.new("db/db.db")
  db.execute("INSERT INTO user_visual_novel_relation (user_status, user_score, user_id) VALUES (?,?,?)", user_status, user_score, user_id)
  redirect("/user_visual_novel_relation")
end

# ///////////////////////////////////////////
# post('/albums/:id/delete') do
#   id = params[:id].to_i
#   db = SQLite3::Database.new("db/chinook-crud.db")
#   db.execute("DELETE FROM albums WHERE AlbumId = ?", id)
#   redirect("/albums")
# end

# post('/albums/:id/update') do
#   id = params[:id].to_i
#   title = params[:title]
#   artistId = params[:artistId].to_i
#   db = SQLite3::Database.new("db/chinook-crud.db")
#   db.execute("UPDATE albums SET Title=?,artistId=? WHERE AlbumId=?",title,artistId,id)
#   redirect("/albums")
# end

# get('/todos/:id/edit') do
#   id = params[:id].to_i
#   db = SQLite3::Database.new("db/db.db")
#   db.results_as_hash = true
#   result = db.execute("SELECT * FROM todos WHERE id = ?", id).first

#   slim(:"/todos/edit", locals:{result:result})
# end

# ////////////////////////
get('/login') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = initiate_database
  result = all_attr_with_same_value(db, "user", "name", username).first

  if result != nil
      pwdigest = result["password"]
      id = result["id"]
      if BCrypt::Password.new(pwdigest) == password
          session[:id] = id
          redirect("/")
      else
          flash_notice("/login", "Wrong password")
      end
  else
      flash_notice("/login", "Account does not exsist")
  end

end

get('/user_visual_novel_relation') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM user_visual_novel_relation WHERE user_id = ?",id)
  slim(:"user_visual_novel_relation/index", locals:{user_visual_novel_relation:result, id:id})
end

post('/user/new') do
  username = params[:username]
  redirect("/register") if name_exists_in_table?(username, "user")  #   if username existerar i tabell,
    # skicka tillbaka till sidan!
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/db.db')
    db.execute("INSERT INTO user (name, password) VALUES (?,?)", username, password_digest)
    redirect("/")
  else
    "The passwords do not match"
  end
end

 # OBS! gem install sinatra-flash

get('/logout') do
   session[:id] = nil
   flash_notice("/", "You have logged out")
end


before do
  @display_vn_new, @display_login, @display_signin, @display_my_list, @display_delete, @display_logout = "block", "block", "block", "block", "block", "block"
  banned_paths_guest = ["/visual_novel/new", "/user_visual_novel_relation", "/logout"]
  banned_paths_user = ["/visual_novel/new", "/register", "/login"]
  banned_paths_admin = ["/register", "/login"]

  session[:admin] = 3

  if session[:id] == nil
    @display_vn_new,@display_my_list,@display_delete,@display_logout = "none","none","none","none"
    flash_notice("/", "Log in to view this page") if restricted_path?(banned_paths_guest)
  elsif session[:id] == session[:admin]
    @display_login,@display_signin = "none","none"
    flash_notice("/", "Admin cannot access this page") if restricted_path?(banned_paths_admin) 
  else
    @display_login,@display_signin,@display_vn_new,@display_delete = "none","none","none","none"
    flash_notice("/", "User cannot access this page") if restricted_path?(banned_paths_user)
  end
end

helpers do
  def restricted_path?(arr)
    arr.include?(request.path_info)
  end

  def flash_notice(route, str)
    flash[:notice] = str
    redirect(route)
  end
end