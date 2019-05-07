require_relative 'entity'

class System
  attr_accessor :id
  attr_accessor :entities
  attr_accessor :name
  attr_accessor :links
  attr_accessor :type
  attr_accessor :data
  
  @systems = {}

  def self.create_system(options)
    @systems[options['name']] ||= System.new(options['name'])
    @systems[options['name']].configure(options)
    @systems[options['name']]
  end
  
  def self.systems
    @systems.values
  end

  def initialize(name)
    self.name = name
    self.entities = []
    self.links = []
    @data = {}
    self.type = "dependency"
  end

  def url
    "#{@url_prefix}#{id}"
  end

  def configure(options)
    self.id ||= options['id']
    @url_prefix ||= options['url_prefix']
    self.data = self.data.merge(options)
    
    if options.has_key? 'dependencies'
      options['dependencies'].each do |name, entities|
        dep_sys = System.create_system('name' => name, 'url_prefix' => @url_prefix)
        entities.each do |entity|
          new_entity = dep_sys.addEntity(entity)
          self.addLink(new_entity)
        end
      end
    end
  end

  def upstream_dependencies
    deps = self.links.map(&:parent).map(&:upstream_dependencies)
    deps << self.links.map(&:parent)
    deps.flatten
  end
  
  def downstream_dependencies
    deps = self.entities.map(&:dependents).flatten.map(&:downstream_dependencies)
    deps << self.entities.map(&:dependents)
    deps.flatten
  end

  def dependencies
    deps = [self]
    deps << upstream_dependencies
    deps << downstream_dependencies
    deps.flatten.uniq
  end
  
  def addEntity(entity)
    if self.entities.map(&:name).include? entity
      self.entities.select{ |e| e.name == entity }.first
    else
      new_entity = Entity.new(entity, self)
      self.entities << new_entity
      new_entity
    end
  end
  
  def addLink(destEntity)
    destEntity.dependents << self
    self.links << destEntity unless self.links.include? destEntity
  end

  def id
    @id || self.name.downcase.gsub(' ', '_')
  end
end