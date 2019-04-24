require_relative 'lib/system'
require_relative 'lib/graphviz'

module Jekyll
  class SystemPage < Page
    def initialize(site, system)
      @site = site
      @dir = 'systems/' + system.id
      @name = 'index.html'

      self.process(@name)
      self.data = {}
      self.data['layout'] = 'system'
      self.data['title'] = system.name
      self.data['type'] = 'system'
      self.data['system'] = system
      self.data['graph'] = GraphViz::generateDot(system.dependencies)
      true
    end
  end

  class GraphFile < StaticFile
    attr_accessor :data
    
    def initialize(site, path, filename, systems)
      super(site, site.source, path, filename)
      self.data = {'type' => 'full_graph'}
      self.data['foo'] = 'hello'
      self.data['graph'] = GraphViz::generateDot(systems)
      @fileData = data = GraphViz::generateFullGraph(systems)
    end
    
    def write(dest)
      dest_path = destination(dest)

      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.rm(dest_path) if File.exist?(dest_path)
      File.open(dest_path, 'w') { |file| file.write(@fileData) }
      true
    end
  end

  class SystemPageGenerator < Generator
    safe true

    def generate(site)
      return unless site.config['system_mapping'] && site.config['system_mapping']['enabled']
      
      if site.config['system_mapping']['system_maps'] && site.config['system_mapping']['system_maps'].length > 0
        site.config['system_mapping']['system_maps'].each do |system_type|
          if site.data[system_type]
            site.data[system_type].each do |system_id, system_data|
              system_data['id'] = "#{system_type}_#{system_id}"
              sys = System.create_system(system_data)
              sys.type = system_type
            end
          end
        end
      end

      file = GraphFile.new(site, 'systems', 'full_graph.svg', System.systems)
      site.static_files << file
      
      
      System.systems.each do |sys|
        site.pages << SystemPage.new(site, sys)
      end
    end
  end
end