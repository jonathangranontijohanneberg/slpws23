require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

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

    # user_id = session[:id].to_i
    db = SQLite3::Database.new("db/db.db")
    genre_id_arr = db.execute("SELECT id FROM genre WHERE name = ?", genre)
# ALL genre_id
    if genre_id_arr.empty?
        highest_genre_id = db.execute("SELECT MAX(id) FROM genre")

        genre_id = highest_genre_id[0][0].to_i + 1

        db.execute("INSERT INTO genre (name, id) VALUES (?,?)", genre, genre_id)
    else
        genre_id = genre_id_arr[0][0].to_i

    end
        
    # "INSERT INTO visual_novel (name, genre, description) VALUES (?,?, ?)", name, genre_id, text)

    # todo2022.db
    p name
    p genre_id
    p description

    db.execute("INSERT INTO visual_novel (name, genre_id, text) VALUES (?,?,?)", name, genre_id, description)
    redirect("/visual_novel")
end

get('/visual_novel') do
    # id = session[:id].to_i
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM visual_novel")
    # "WHERE user_id = ?",id
    slim(:"visual_novel/index", locals:{visual_novel:result})
end