class Dog
  attr_accessor :id, :name, :breed

  @@all = []

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
    self.id ||= nil
  end

  def self.create_table
    sql =<<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
        
      DB[:conn].execute(sql)
  end 

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs") 
  end 

    def save 
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        self
    end 

    def self.create(dog_hash)
      dog = Dog.new(dog_hash)
      dog.save
    end 

  def self.new_from_db(row)
    hash = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    
    self.new(hash)
  end 

  def self.find_by_id(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first
  end 

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
    if dog
      new = self.new_from_db(dog)
    else
      new = self.create(name: name, breed: breed)
    end
    new
  end 

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL

      DB[:conn].execute(sql, name).map do |row|
        Dog.new_from_db(row)
      end.first
   end 

  def update 
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 

end