require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
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
    genre = params[:genre]
    description = params[:description]
    creator = params[:creator]
    db = initiate_database
    genre_id = attribute_id(genre, "genre", db)
    creator_id = attribute_id(creator, "creator", db)
    visual_novel_id = attribute_id(name, "visual_novel", db)

    # db.execute("INSERT INTO visual_novel (name, genre_id, text, creator_id) VALUES (?,?,?,?)", name, genre_id, description, creator_id)
    insert_into_table_four_attributes(db, "visual_novel", "name, genre_id, text, creator_id", "?,?,?,?", name, genre_id, description, creator_id)
    # db.execute("INSERT INTO visual_novel_creator_relation (visual_novel_id, creator_id) VALUES (?,?)", visual_novel_id, creator_id)
    insert_into_table_two_attributes(db, "visual_novel_creator_relation", "visual_novel_id, creator_id", "?,?", visual_novel_id, creator_id)

    redirect("/visual_novel")
end

get('/visual_novel') do
    db = initiate_database
    result = select_all_table_attributes(db, "visual_novel")
    result2 = select_all_table_attributes(db, "genre")
    slim(:"visual_novel/index", locals:{visual_novel:result, genre: result2})
end

# #############################FORTSÄTT NEDAN MED EDIT/UPDATE NÄSTA GÅNG!#################
post('/visual_novel/:id/update') do
    id = params[:id].to_i
    title = params[:title]
    artistId = params[:artistId].to_i
    db = SQLite3::Database.new("db/chinook-crud.db")
    db.execute("UPDATE albums SET Title=?,artistId=? WHERE AlbumId=?",title,artistId,id)
    redirect("/visual_novels")
end
  
get('/albums/:id/edit') do
    id = params[:id].to_i
    db = initiate_database
    result = select_table_attributes_with_same_id(db, "visual_novel", "id", id).first

    slim(:"/visual_novels/edit", locals:{visual_novel:result})
end
# #############################FORTSÄTT OVAN MED EDIT/UPDATE NÄSTA GÅNG!#################

  

get('/visual_novel/:id') do
    id = params[:id].to_i
    db = initiate_database
    result = select_table_attributes_with_same_id(db, "visual_novel", "id", id).first
    result2 = select_table_attributes_with_same_id(db, "genre", "id", result['genre_id']).first
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
    result = select_table_attributes_with_same_id(db, "visual_novel", "genre_id", genre_id)
    result2 = select_table_attributes_with_same_id(db, "genre", "id", genre_id).first
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
    result = select_table_attributes_with_same_id(db, "visual_novel", "creator_id", creator_id)
    result2 = select_table_attributes_with_same_id(db, "genre", "id", result.first['genre_id'].to_i).first
    result3 = select_table_attributes_with_same_id(db, "creator", "id", creator_id).first

    slim(:"creator/show", locals:{visual_novel: result, genre: result2, creator: result3})
end



# SQL-kod flyttas till model.rb istället för helpern!
helpers do

end