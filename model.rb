

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