module Model
        # Finds the id of an attribute and creates a new if one doesn't exist
    #
    # @param [String] attribute name of name-attribute
    # @param [String] table name of the entity
    #
    # @return [Integer] attribute_id, id of inputted attribute
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

        # Inserts two values into attributes of a table
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] table name of table
    # @param [String] attr1 name of first attribute
    # @param [String] attr2 name of second attribute
    # @param [String] value1 value of first attribute
    # @param [String] value2 value of second attribute
    #
    # @return [void]
    def insert_into_table_two_attributes(db, table, attr1, attr2, value1, value2) 
        db.execute("INSERT INTO #{table} (#{attr1}, #{attr2}) VALUES (?,?)", value1, value2)
    end

        # updates all attributes in visual novel entity
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] name name of name attribute
    # @param [Integer] genre_id id of genre
    # @param [String] description description of visual novel
    # @param [Integer] creator_id id of creator
    # @param [Integer] id id of visual_novel
    #
    # @return [void]
    def update_visual_novel_table(db, name, genre_id, description, creator_id, id)
        db.execute("UPDATE visual_novel SET name = ?, genre_id = ?, text = ?, creator_id = ? WHERE id = ?", name, genre_id, description, creator_id, id)
    end

        # updates creator id attribute in relation table for visual novel and creator
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [Integer] visual_novel_id id of visual_novel
    # @param [Integer] creator_id id of creator
    #
    # @return [void]
    def update_visual_novel_creator_relation(db, visual_novel_id, creator_id)
        db.execute("UPDATE visual_novel_creator_relation SET creator_id = ? WHERE visual_novel_id = ?", creator_id, visual_novel_id)
    end

        # updates all attributes in relation table for visual novel and user
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] user_status status of user on a visual novel
    # @param [Float] user_score score of user on a visual novel
    # @param [Integer] user_id id of user
    # @param [Integer] visual_novel_id id of visual_novel
    #
    # @return [void]
    def update_user_visual_novel_relation_table(db, user_status, user_score, user_id, visual_novel_id)
        db.execute("UPDATE user_visual_novel_relation SET user_status = ?, user_score = ? WHERE user_id = ? AND visual_novel_id = ?", user_status, user_score, user_id, visual_novel_id)
    end

        # Selects ids from the visual_novel table using the name attribute
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] name name of visual novel
    #
    # @return [Array] an array potentially containing hashes with strings depending on input
    def id_with_name(db, name)
        db.execute("SELECT id FROM visual_novel WHERE name=?", name)
    end

        # Selects all attributes from the inputted table
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] table name of table
    #
    # @return [Array] an array potentially containing hashes with strings depending on input
    def select_all_table_attributes(db, table)
        db.execute("SELECT * FROM #{table}")
    end

        # Selects all attributes from the inputted table
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] table name of table
    #
    # @return [Array] an array potentially containing hashes with strings depending on input
    def all_attr_with_same_value(db, table, attr1, value1)
        db.execute("SELECT * FROM #{table} WHERE #{attr1} = ?", value1)
    end

        # Selects all attributes from the inputted table by matching two inputted attributes with two inputted values
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] table name of table
    # @param [String] attr1 name of first attribute
    # @param [String] attr2 name of second attribute
    # @param [String] value1 value of first attribute
    # @param [String] value2 value of second attribute
    #
    # @return [Array] an array potentially containing hashes with strings depending on input
    def all_attr_with_same_value_two_attr(db, table, attr1, attr2, value1, value2)
        db.execute("SELECT * FROM #{table} WHERE #{attr1}=? AND #{attr2}=?", value1, value2)
    end

        # Deletes all attributes of an entity using one attribute and value
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] table name of table
    # @param [String] id1 inputted attribute name
    # @param [Integer] id2 inputted id
    #
    # @return [void]
    def delete_table_attributes_with_same_id(db, table, id1, id2)
        db.execute("DELETE FROM #{table} WHERE #{id1} = ?", id2)
    end

        # Deletes all attributes of an entity using two attributes and values
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] table name of table
    # @param [String] attr_id1 inputted attribute name
    # @param [String] attr_id2 second inputted attribute name
    # @param [Integer] id1 first id
    # @param [Integer] id2 second id
    #
    # @return [void]
    def delete_table_attributes_with_same_id_two_attr(db, table, attr_id1, attr_id2, id1, id2)
        db.execute("DELETE FROM user_visual_novel_relation WHERE #{attr_id1} = ? AND #{attr_id2} = ?", id1, id2)
    end

        # Inserts four values into the visual novel table
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] value1 first inputted value
    # @param [String] value2 second inputted value
    # @param [String] value3 third inputted value
    # @param [String] value4 fourth inputted value
    #
    # @return [void]
    def insert_into_visual_novel_four_attributes(db, value1, value2, value3, value4)
        db.execute("INSERT INTO visual_novel (name, genre_id, text, creator_id) VALUES (?,?,?,?)", value1, value2, value3, value4)
    end

        # Inserts four values into the relation table for visual novel and user
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [Integer] user_id id of user
    # @param [Integer] visual_novel_id id of visual novel
    # @param [String] user_status status of user on the visual novel
    # @param [Float] user_score score of user on the visual novel
    #
    # @return [void]
    def insert_into_user_visual_novel_relation_four_attributes(db, user_id, visual_novel_id, user_status, user_score)
        db.execute("INSERT INTO user_visual_novel_relation (user_id, visual_novel_id, user_status, user_score) VALUES (?,?,?,?)", user_id, visual_novel_id, user_status, user_score)
    end

        # Inserts three values into the relation table for visual novel and user
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [String] user_status status of user on the visual novel
    # @param [Float] user_score score of user on the visual novel
    # @param [Integer] user_id id of user
    #
    # @return [void]
    def insert_into_user_visual_novel_relation_three_attributes(db, user_status, user_score, user_id)
        db.execute("INSERT INTO user_visual_novel_relation (user_status, user_score, user_id) VALUES (?,?,?)", user_status, user_score, user_id)
    end

        # Inserts two values into the relation table for visual novel and user
    #
    # @param [SQLite3::Database] db the database with result as hash
    # @param [Integer] value1 first inputted id value
    # @param [Integer] value2 second inputted id value
    #
    # @return [void]
    def insert_into_visual_novel_creator_relation_two_attributes(db, value1, value2)
        db.execute("INSERT INTO visual_novel_creator_relation (visual_novel_id, creator_id) VALUES (?,?)", value1, value2)
    end

        # Selects name from the inputted table by matching the id attribute with inputted id
    #
    # @param [Integer] id inputted id
    #
    # @return [Array] an array potentially containing hashes with strings of names depending on input
    def name_with_id(table, id)
        db = initiate_database
        db.execute("SELECT name FROM #{table} WHERE id=?", id)[0]["name"]
    end

        # Checks if there exists an id in the inputted table that contains the inputted name
    #
    # @param [String] name value of the name entity
    # @param [String] table name of the entity
    #
    # @return [Array] an array potentially containing hashes with strings depending on input
    def name_exists_in_table?(name, table)
        db = initiate_database
        db.execute("SELECT id FROM #{table} WHERE name=?", name) != []
    end

        # Makes a new object of the database class and makes it contain hashes
    #
    # @return [SQLite3::Database] db the database with result as hash
    def initiate_database
        db = SQLite3::Database.new('db/db.db')
        db.results_as_hash = true
        return db
    end
end