require 'active_support/inflector'
module Associatable

  class HasManyParams
    attr_accessor :name, :params
    def initialize(name, *params)
      @name = name
      @params = params == [] ? Hash.new : params[0]
    end

    def other_class
      params[:class_name] ? params[:class_name].constantize : name.to_s.camelize.singularize.constantize
    end

    def other_table
      other_class.table_name
    end

    def foreign_key
      params[:foreign_key] || "#{name}_id".to_sym
    end

    def primary_key
      params[:primary_key] || :id
    end

  end

  def has_one_through

  end

  def belongs_to(assoc_name, *params)

    self.send(:define_method, assoc_name) do 
      paramsz = params == [] ? Hash.new : params[0]
      paramsz[:table_name] = paramsz[:class_name] ? paramsz[:class_name].constantize.table_name : assoc_name.to_s.camelize.constantize.table_name
      paramsz[:primary_key] = paramsz[:primary_key] ? paramsz[:primary_key].to_s : :id.to_s
      paramsz[:foreign_key] = paramsz[:foreign_key] ? paramsz[:foreign_key] : "#{assoc_name}_id".to_sym
      other_table_name = paramsz[:table_name]
      prim_key = paramsz[:primary_key]
      foreign_value = self.send(paramsz[:foreign_key])
      result = DBConnection.execute(<<-SQL)
                  SELECT *
                    FROM #{other_table_name}
                    WHERE #{prim_key} = #{foreign_value}
                SQL
      assoc_name.to_s.capitalize.constantize.parse_all(result)[0]
    end
  end

  def has_many(assoc_name, *params)

    self.send(:define_method, assoc_name) do 
      paramsz = params == [] ? Hash.new : params[0]

      paramsz[:table_name] = paramsz[:class_name] ? paramsz[:class_name].constantize.table_name : assoc_name.to_s.singularize.camelize.constantize.table_name
      paramsz[:primary_key] = paramsz[:primary_key] ? paramsz[:primary_key].to_s : :id.to_s
      paramsz[:foreign_key] = paramsz[:foreign_key] ? paramsz[:foreign_key] : "#{assoc_name}_id".to_sym
      table_name = paramsz[:table_name]
      key = paramsz[:foreign_key]
      value = self.send(paramsz[:primary_key])

      result = DBConnection.execute(<<-SQL)
                  SELECT *
                    FROM #{table_name}
                    WHERE #{key} = #{value}
                SQL
      assoc_name.to_s.capitalize.singularize.constantize.parse_all(result)
    end
  end

end