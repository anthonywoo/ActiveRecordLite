#Cat.where({:column1 => 2, :column2 => 3})
module Searchable #ALl methods are class methods

def where(params)
  where_clause = params.keys.map{|key| "#{key} = ?" }.join(" AND ")
  values = params.values
  results = DBConnection.execute(<<-SQL, *values)
                  SELECT *
                  FROM #{self.table_name}
                  WHERE (#{where_clause})
                SQL
  get_objects(results)
end

end