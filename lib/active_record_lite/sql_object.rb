class SQLObject < MassObject

  extend ::Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table = table_name
  end

  def self.table_name
    @table
  end

  def self.all
    table = self.table_name
    result = DBConnection.execute(<<-SQL)
      SELECT *
        FROM #{table}
    SQL
    all = get_objects(result)
    all
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL)
                SELECT *
                  FROM #{table_name}
                  WHERE id = #{id}
              SQL
    obj = get_objects(result)
    obj[0]
  end

  def create
    attr_names = self.class.attributes.join(", ")

    question_marks = (["?"] * self.class.attributes.length).join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
                  INSERT INTO #{self.class.table_name} (#{attr_names})
                  VALUES (#{question_marks})
                SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.attributes.map{ |attr_name| "#{attr_name} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
                      UPDATE #{self.class.table_name}
                      SET #{set_line}
                      WHERE #{self.class.table_name}.id = #{self.id}
                    SQL
  end

  def save
    self.id ? update : create
  end


  private

  def self.get_objects(result)
    result.map{|params| self.new(params)}
  end

  def attribute_values
    self.class.attributes.map{|attr_name| self.send(attr_name)}
  end
end

