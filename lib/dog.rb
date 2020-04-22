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
      dog_hash = {
        id: => row[0]
        name: => row[1]
        breed: => row[2]
      }
    end 

  def self.find_by_id(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      result = DB[:conn].execute(sql, id)[0]
      Dog.new(result[0], result[1], result[2])

  end 

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(dog_info[0], dog_info[1], dog_info[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
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