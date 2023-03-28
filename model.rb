
# HIT ÅKER ALL SQL-KOD
# MVC-slide på classroom
# MODULE
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


def id_with_name(db, name)
    db.execute("SELECT id FROM visual_novel WHERE name=?", name)
end

def select_all_table_attributes(db, table)
    db.execute("SELECT * FROM #{table}")
end

def select_table_attributes_with_same_id(db, table, id1, id2)
    db.execute("SELECT * FROM #{table} WHERE #{id1} = ?", id2)
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
    db.execute("SELECT name FROM #{table} WHERE id=?",id)[0]["name"]
end

def initiate_database
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    return db
end