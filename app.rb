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
    visual_novel_id = db.execute("SELECT id FROM visual_novel WHERE name=?", name)

    db.execute("INSERT INTO visual_novel (name, genre_id, text, creator_id) VALUES (?,?,?,?)", name, genre_id, description, creator_id)
    db.execute("INSERT INTO visual_novel_creator_relation (visual_novel_id, creator_id) VALUES (?,?)", visual_novel_id, creator_id)

    redirect("/visual_novel")
end

get('/visual_novel') do
    # id = session[:id].to_i
    db = initiate_database
    result = db.execute("SELECT * FROM visual_novel")
    result2 = db.execute("SELECT * FROM genre")
    slim(:"visual_novel/index", locals:{visual_novel:result, genre: result2})
end

get('/visual_novel/:id') do
    id = params[:id].to_i
    db = initiate_database
    result = db.execute("SELECT * FROM visual_novel WHERE id = ?",id).first
    result2 = db.execute("SELECT * FROM genre WHERE id = ?", result['genre_id']).first

    slim(:"visual_novel/show",locals:{visual_novel: result, genre: result2})
end

post('/visual_novel/:id/delete') do
    id = params[:id].to_i
    db = initiate_database
    db.execute("DELETE FROM visual_novel WHERE id = ?", id)
    db.execute("DELETE FROM visual_novel_creator_relation WHERE visual_novel_id = ?", id)
    redirect("/visual_novel")
end


get('/genre') do
    # id = session[:id].to_i
    db = initiate_database
    result = db.execute("SELECT * FROM visual_novel")
    result2 = db.execute("SELECT * FROM genre")

    slim(:"genre/index", locals:{visual_novel: result, genre: result2})
end

get('/genre/:id') do
    genre_id = params[:id].to_i
    db = initiate_database
    result = db.execute("SELECT * FROM visual_novel WHERE genre_id = ?", genre_id)
    result2 = db.execute("SELECT * FROM genre WHERE id = ?",genre_id).first

    slim(:"genre/show",locals:{visual_novel: result, genre: result2})
end



get('/creator') do
    # id = session[:id].to_i
    db = initiate_database
    result = db.execute("SELECT * FROM visual_novel")

    result2 = db.execute("SELECT * FROM genre")

    result3 = db.execute("SELECT * FROM creator")

    slim(:"creator/index", locals:{visual_novel: result, genre: result2, creator: result3})
end

get('/creator/:id') do
    creator_id = params[:id].to_i
    db = initiate_database
    result = db.execute("SELECT * FROM visual_novel WHERE creator_id = ?", creator_id)

    result2 = db.execute("SELECT * FROM genre WHERE id = ?", result.first['genre_id'].to_i).first

    result3 = db.execute("SELECT * FROM creator WHERE id = ?", creator_id).first

    slim(:"creator/show", locals:{visual_novel: result, genre: result2, creator: result3})
end




helpers do

    def all_visual_novels
        db = initiate_database

        result = db.execute("SELECT * FROM visual_novel")
        return result
    end

    def name_with_id(table, id)
        db = initiate_database

        name = db.execute("SELECT name FROM #{table} WHERE id=?",id)[0]["name"]
        return name
    end
   
    def initiate_database
        db = SQLite3::Database.new('db/db.db')
        db.results_as_hash = true
        return db
    end
end