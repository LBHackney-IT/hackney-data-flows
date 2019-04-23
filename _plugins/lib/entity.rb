class Entity
  attr_accessor :name
  attr_accessor :parent
  attr_accessor :dependents

  def initialize(name, parent)
    self.name = name
    self.parent = parent
    @dependents = []
  end
  
  def id
    self.name.downcase.gsub(' ', '_')
  end
end