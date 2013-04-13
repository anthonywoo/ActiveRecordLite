class MassObject

  def self.set_attrs(*attributes)
    attributes.each do |attr|
      attr_accessor attr
    end
    @attributes = attributes
  end

  def self.attributes
    @attributes
  end

  def initialize(params = [])
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "Mass Assignemnt to unregistered attribute #{attr_name}"
      end
    end
  end

  def self.parse_all(result)
    result.map{|params| self.new(params)}
  end

end