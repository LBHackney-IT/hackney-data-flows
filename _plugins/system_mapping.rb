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
      true
    end
  end

  class GraphFile < StaticFile
    def write(dest)
      dest_path = destination(dest)

      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.rm(dest_path) if File.exist?(dest_path)
      File.open(dest_path, 'w') { |file| file.write(@fileData) }
      true
    end
    
    def setFileData(data)
      @fileData = data
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

      graphData = GraphViz::generateFullGraph(System.systems)
      file = GraphFile.new(site, site.source, 'systems', 'full_graph.svg')
      file.setFileData(graphData)
      site.static_files << file

      System.systems.each do |sys|
        site.pages << SystemPage.new(site, sys)

        graphData = GraphViz::generateSingleGraph(sys)
        file = GraphFile.new(site, site.source, 'systems/' + sys.id, 'graph.svg')
        file.setFileData(graphData)
        site.static_files << file
      end

    end
  end
end