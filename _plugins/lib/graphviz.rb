require 'open3'

module GraphViz
  def self.generateFullGraph(systems)
    graphData = diagraph do
      output = []
      systems.group_by(&:type).each do |type, systems|
        output << "subgraph cluster_#{type} {"
        output << 'style="filled";'
        output << "color=lightgrey;"
        output << "node [style=filled,fillcolor=white];"
        output << 'rank="same"'
        output << systems.map{ |s| systemNodeName(s) }
        output << '}'
      end
      output << systems.map{ |s| systemLinks(s, systems) }
      output.flatten.compact.join("\n")
    end
    generateGraph(graphData)
  end
  
  def self.generateSingleGraph(system)
    subsystems = system.dependencies
    generateFullGraph(subsystems)
  end

  def self.systemNodeName(system, options={})
    if system.entities.length > 0
      "#{system.id} [label=\"{#{system.name} | {#{system.entities.map{ |e| entityNodeName(e) }.join('|')}}}\"];"
    else
      "#{system.id} [label=\"#{system.name}\"];"
    end
  end

  def self.entityNodeName(entity)
    "<#{entity.id}> #{entity.name}"
  end

  def self.systemLinks(system, systems)
    system.links.map { |link|
      if systems.include? link.parent
        "#{system.id} -> #{link.parent.id}:#{link.id}"
      end
    }.compact
  end

  def self.generateGraph(graphData)
    output = ''
    Open3.popen2("dot -Tsvg") {|i,o,t|
      i.print graphData
      i.close
      output = o.read
    }
    output
  end
  
  def self.diagraph &block
    return %|digraph G {\nnode [shape=record];\ngraph [pad="0.5", ranksep="5"];\nrankdir=RL;\n#{block.call}\n}|
  end

  def cluster &block
  
  end
end



def generate_graph(systems)
  output = ['digraph G {', 'node [shape=record];', 'graph [pad="0.5", ranksep="4"];', 'rankdir=RL']
  systems.values.group_by(&:type).each do |type, systems|
    output << "subgraph cluster_#{type} {"
    output << 'rank="same"'
    output << systems.map(&:graphVizNodeName)
    output << '}'    
  end
  output << systems.values.map(&:graphVizLinks)
  output << '}'
  output.flatten.compact.join("\n")
end