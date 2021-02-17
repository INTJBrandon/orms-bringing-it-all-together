class Dog
attr_accessor :name, :breed, :id

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
            SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create(hash)
        dog = self.new(hash)
        dog.save
        dog
    end

    def self.new_from_db(array)
        self.new(id:array[0], name:array[1], breed:array[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?;
            SQL
        array = DB[:conn].execute(sql, id)[0]
        self.new_from_db(array)
    end

    def self.find_or_create_by(hash)
        if self.find_by_name(hash[:name]).breed == hash[:breed]
            self.find_by_name(hash[:name]) 
        else 
            self.create(hash)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?;
            SQL
        array = DB[:conn].execute(sql, name)[0]
        self.new_from_db(array)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
            SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end