require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative './model.rb'

enable :sessions

include Model

# Displays Home Page
#
get('/') do
    slim(:home)
end

# Displays a page for adding visual novels
# 
get('/visual_novel/new') do
    slim(:"visual_novel/new")
end

# Creates new visual novel or updates existing visual novel and redirects to "/visual_novel" or "/visual_novel/new" if name-field is left blank.
#
# @param [String] name, The name of the visual_novel
# @param [String] genre, The genre of the visual_novel
# @param [String] description, The description-text of the visual_novel
# @param [String] creator, The creator of the visual_novel

# @see Model#attribute_id#id_with_name#update_visual_novel_table#update_visual_novel_creator_relation#insert_into_visual_novel_four_attributes#insert_into_visual_novel_creator_relation_two_attributes#initiate_database
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

    id = id_with_name(db, name)
    if id != []
        id = id[0]["id"]
        update_visual_novel_table(db, name, genre_id, description, creator_id, id)
        update_visual_novel_creator_relation(db, id, creator_id)
    else
        insert_into_visual_novel_four_attributes(db, name, genre_id, description, creator_id)
        insert_into_visual_novel_creator_relation_two_attributes(db, visual_novel_id, creator_id)
    end
    redirect("/visual_novel")
end


# Displays index-page with all visual novels.

# @see Model#select_all_table_attributes#initiate_database
get('/visual_novel') do
    db = initiate_database
    result = select_all_table_attributes(db, "visual_novel")
    result2 = select_all_table_attributes(db, "genre")
    slim(:"visual_novel/index", locals:{visual_novel:result, genre: result2})
end  

# Displays one visual novel
#
# @param [Integer] id, The id of the visual_novel

# @see Model#all_attr_with_same_value#initiate_database
get('/visual_novel/:id') do
    id = params[:id].to_i
    db = initiate_database
    result = all_attr_with_same_value(db, "visual_novel", "id", id).first
    result2 = all_attr_with_same_value(db, "genre", "id", result['genre_id']).first
    slim(:"visual_novel/show",locals:{visual_novel: result, genre: result2})
end

# Deletes a visual novel and redirects to "/visual_novel"
#
# @param [Integer] id, The id of the visual_novel

# @see Model#delete_table_attributes_with_same_id#initiate_database
post('/visual_novel/:id/delete') do
    id = params[:id].to_i
    db = initiate_database
    delete_table_attributes_with_same_id(db, "visual_novel", "id", id)
    delete_table_attributes_with_same_id(db, "visual_novel_creator_relation", "visual_novel_id", id)
    delete_table_attributes_with_same_id(db, "user_visual_novel_relation", "visual_novel_id", id)
    redirect("/visual_novel")
end

# Displays all genres

# @see Model#select_all_table_attributes#initiate_database
get('/genre') do
    db = initiate_database
    result = select_all_table_attributes(db, "visual_novel")
    result2 = select_all_table_attributes(db, "genre")
    slim(:"genre/index", locals:{visual_novel: result, genre: result2})
end

# Displays one genre
#
# @param [Integer] id, The id of the visual_novel

# @see Model#all_attr_with_same_value#initiate_database
get('/genre/:id') do
    genre_id = params[:id].to_i
    db = initiate_database
    result = all_attr_with_same_value(db, "visual_novel", "genre_id", genre_id)
    result2 = all_attr_with_same_value(db, "genre", "id", genre_id).first
    slim(:"genre/show",locals:{visual_novel: result, genre: result2})
end

# Displays all creators

# @see Model#select_all_table_attributes#initiate_database
get('/creator') do
    db = initiate_database
    result = select_all_table_attributes(db, "visual_novel")
    result2 = select_all_table_attributes(db, "genre")
    result3 = select_all_table_attributes(db, "creator")
    slim(:"creator/index", locals:{visual_novel: result, genre: result2, creator: result3})
end

# Displays one creator
#
# @param [Integer] id, The id of the visual_novel

# @see Model#all_attr_with_same_value#initiate_database
get('/creator/:id') do
    creator_id = params[:id].to_i
    db = initiate_database
    result = all_attr_with_same_value(db, "visual_novel", "creator_id", creator_id)
    result2 = all_attr_with_same_value(db, "creator", "id", creator_id).first
    slim(:"creator/show", locals:{visual_novel: result, creator: result2})
end

# Displays Register page
#
get('/register') do
  slim(:register)
end

get('/user_visual_novel_relation/new') do
  if params[:id] == nil
    flash_notice("/visual_novel", "Please add a visual novel")
  else
    slim(:"visual_novel/show")
  end
end

# Adds visual novel and user ids to relation table along with score and status or updates them if they already exist and redirects to "/user_visual_novel_relation"
#
# @param [String] status, The user's status on the visual_novel
# @param [Float] score, The user's grading of the visual_novel
# @param [Integer] id, The id of the visual_novel

# @see Model#all_attr_with_same_value_two_attr#update_user_visual_novel_relation_table#insert_into_user_visual_novel_relation_four_attributes#initiate_database
post('/user_visual_novel_relation/new') do
  user_status = params[:status]
  user_score = params[:score]
  id = params[:id].to_i
  user_id = session[:id]
  db = initiate_database

  user_vn_rel = all_attr_with_same_value_two_attr(db, "user_visual_novel_relation", "user_id", "visual_novel_id", user_id, id)
  if user_vn_rel != []
    update_user_visual_novel_relation_table(db, user_status, user_score, user_id, id)
  else
    insert_into_user_visual_novel_relation_four_attributes(db, user_id, id, user_status, user_score)
  end
  redirect("/user_visual_novel_relation")
end

# Deletes row where visual novel and user ids match in the relation table and redirects to "/user_visual_novel_relation"
#
# @param [Integer] id, The id of the visual_novel

# @see Model#delete_table_attributes_with_same_id_two_attr#initiate_database
post('/user_visual_novel_relation/:id/delete') do
  id = params[:id].to_i
  user_id = session[:id].to_i
  db = initiate_database
  delete_table_attributes_with_same_id_two_attr(db, "user_visual_novel_relation", "user_id", "visual_novel_id", user_id, id)
  redirect("/user_visual_novel_relation")
end

# Inserts status, score and user id into the relation table and redirects to "/user_visual_novel_relation"
#
# @param [String] status, The user's status on the visual_novel
# @param [Float] score, The user's grading of the visual_novel
# @param [Integer] id, The id of the visual_novel

# @see Model#insert_into_user_visual_novel_relation_three_attributes#initiate_database
post('/user_visual_novel_relation') do
  user_status = params[:status]
  user_score = params[:score]
  user_id = session[:id].to_i
  db = initiate_database
  insert_into_user_visual_novel_relation_three_attributes(db, user_status, user_score, user_id)
  redirect("/user_visual_novel_relation")
end

# Displays Login Page
#
get('/login') do
  slim(:login)
end

# Logs user in if encrypted passwords match and redirects to "/login" or "/"
#
# @param [String] username, The user's name
# @param [String] password, The user's password

# @see Model#all_attr_with_same_value#initiate_database
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

# Displays all visual novels in a user's list
#
# @param [Integer] id, The id of the visual_novel

# @see Model#all_attr_with_same_value#initiate_database
get('/user_visual_novel_relation') do
  id = session[:id].to_i
  db = initiate_database
  result = all_attr_with_same_value(db, "user_visual_novel_relation", "user_id", id)
  slim(:"user_visual_novel_relation/index", locals:{user_visual_novel_relation:result, id:id})
end

# Adds user with name and encrypted password to database if passwords match name is unique and redirects to "/" or "/register"
#
# @param [String] username, The user's name
# @param [String] password, The user's password
# @param [String] password_confirm, The user's second inputted password

# @see Model#name_exists_in_table#insert_into_table_two_attributes#initiate_database
post('/user/new') do
  username = params[:username]
  redirect("/register") if name_exists_in_table?(username, "user")
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = initiate_database
    insert_into_table_two_attributes(db, "user", "name", "password", username, password_digest)    
    redirect("/")
  else
    "The passwords do not match"
  end
end

# Displays Home Page
# 
get('/logout') do
   session[:id] = nil
   flash_notice("/", "You have logged out")
end

before do
  @display_vn_new, @display_login, @display_signin, @display_my_list, @display_delete, @display_logout, @display_user_vn_rel_new, @display_delete_from_list = "block", "block", "block", "block", "block", "block", "block", "block"
  banned_paths_guest = ["/visual_novel/new", "/user_visual_novel_relation", "/logout", "/user_visual_novel_relation/new"]
  banned_paths_user = ["/visual_novel/new", "/register", "/login"]
  banned_paths_admin = ["/register", "/login"]

  session[:admin] = 3

  if session[:id] == nil
    @display_vn_new,@display_my_list,@display_delete,@display_logout,@display_user_vn_rel_new = "none","none","none","none","none"
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
    # Returns value of visibility för display in CSS
  #
  # @param [Integer] user_id id of the user
  # @param [Integer] visual_novel_id id of the visual_novel
  #
  # @return [String] "none"
  # @return [String] "block"
  def delete_from_list_visibility(user_id, visual_novel_id)
    db = initiate_database
    list_entry_info = all_attr_with_same_value_two_attr(db, "user_visual_novel_relation", "user_id", "visual_novel_id", user_id, visual_novel_id)

    if list_entry_info == []
      "none"
    else
      "block"
    end
  end

    # Checks whether inputted array contains the current path
  #
  # @param [Array] arr array containing strings of paths
  # @option params [String]
  #
  # @return [Boolean] whether current path is included in array
  def restricted_path?(arr)
    arr.include?(request.path_info)
  end

    # Defines flash message and redirects to a path
  #
  # @param [String] route name of route
  # @param [String] str message for flash notice
  #
  # @return [void]
  def flash_notice(route, str)
    flash[:notice] = str
    redirect(route)
  end
end