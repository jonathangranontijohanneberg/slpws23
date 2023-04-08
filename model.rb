
# HIT ÅKER ALL SQL-KOD
# MVC-slide på classroom

def attribute_id(attribute, table, db)
    attribute_id_arr = db.execute("SELECT id FROM #{table} WHERE name = ?", attribute)

    if attribute_id_arr.empty?
        highest_id = db.execute("SELECT MAX(id) FROM #{table}")
        attribute_id = highest_id[0][0].to_i + 1
        if table != "visual_novel"
            db.execute("INSERT INTO #{table} (name, id) VALUES (?,?)", attribute, attribute_id)
        end
    else
        attribute_id = attribute_id_arr[0][0].to_i
    end
    return attribute_id
end

def update_visual_novel_table(db, name, genre_id, description, creator_id, id)
    db.execute("UPDATE visual_novel SET (name, genre_id, text, creator_id) VALUES (?,?,?,?) WHERE id = ?", name, genre_id, description, creator_id, id)
end

def update_visual_novel_creator_relation(db, id, creator_id)
    db.execute("UPDATE visual_novel_creator_relation SET creator_id = ? WHERE visual_novel_id = ?", creator_id, id)
end

def id_with_name(db, name)
    db.execute("SELECT id FROM visual_novel WHERE name=?", name)
end

def select_all_table_attributes(db, table)
    db.execute("SELECT * FROM #{table}")
end

def all_attr_with_same_value(db, table, attr1, value1)
    db.execute("SELECT * FROM #{table} WHERE #{attr1} = ?", value1)
end

def all_attr_with_same_value_two_attr(db, table, attr1, attr2, value1, value2)
    db.execute("SELECT * FROM #{table} WHERE #{attr1}=? AND #{attr2}=?", value1, value2)
end

def delete_table_attributes_with_same_id(db, table, id1, id2)
    db.execute("DELETE FROM #{table} WHERE #{id1} = ?", id2)
end

# fungerara inte1!
def insert_into_table_four_attributes(db, value1, value2, value3, value4)
    db.execute("INSERT INTO visual_novel (name, genre_id, text, creator_id) VALUES (?,?,?,?)", value1, value2, value3, value4)
end

def insert_into_table_two_attributes(db, value1, value2)
    db.execute("INSERT INTO visual_novel_creator_relation (visual_novel_id, creator_id) VALUES (?,?)", value1, value2)
end

def name_with_id(table, id)
    db = initiate_database
    db.execute("SELECT name FROM #{table} WHERE id=?", id)[0]["name"]
end

def name_exists_in_table?(name, table)
    db = initiate_database
    db.execute("SELECT id FROM #{table} WHERE name=?", name) != []
end

# gör detta i en initialize med @ eller global så alla slipper öppna den varje gång?
def initiate_database
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    return db
end
