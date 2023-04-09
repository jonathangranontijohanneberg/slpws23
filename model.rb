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

def insert_into_table_two_attributes(db, table, attr1, attr2, value1, value2) 
    db.execute("INSERT INTO #{table} (#{attr1}, #{attr2}) VALUES (?,?)", value1, value2)
end

def update_visual_novel_table(db, name, genre_id, description, creator_id, id)
    db.execute("UPDATE visual_novel SET name = ?, genre_id = ?, text = ?, creator_id = ? WHERE id = ?", name, genre_id, description, creator_id, id)
end

def update_visual_novel_creator_relation(db, visual_novel_id, creator_id)
    db.execute("UPDATE visual_novel_creator_relation SET creator_id = ? WHERE visual_novel_id = ?", creator_id, visual_novel_id)
end

def update_user_visual_novel_relation_table(db, user_status, user_score, user_id, visual_novel_id)
    db.execute("UPDATE user_visual_novel_relation SET user_status = ?, user_score = ? WHERE user_id = ? AND visual_novel_id = ?", user_status, user_score, user_id, visual_novel_id)
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
def delete_table_attributes_with_same_id_two_attr(db, table, attr_id1, attr_id2, id1, id2)
    db.execute("DELETE FROM user_visual_novel_relation WHERE #{attr_id1} = ? AND #{attr_id2} = ?", id1, id2)
end
def insert_into_visual_novel_four_attributes(db, value1, value2, value3, value4)
    db.execute("INSERT INTO visual_novel (name, genre_id, text, creator_id) VALUES (?,?,?,?)", value1, value2, value3, value4)
end

def insert_into_user_visual_novel_relation_four_attributes(db, user_id, visual_novel_id, user_status, user_score)
    db.execute("INSERT INTO user_visual_novel_relation (user_id, visual_novel_id, user_status, user_score) VALUES (?,?,?,?)", user_id, visual_novel_id, user_status, user_score)
end

def insert_into_user_visual_novel_relation_three_attributes(db, user_status, user_score, user_id)
    db.execute("INSERT INTO user_visual_novel_relation (user_status, user_score, user_id) VALUES (?,?,?)", user_status, user_score, user_id)
end

def insert_into_visual_novel_creator_relation_two_attributes(db, value1, value2)
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

def initiate_database
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    return db
end
