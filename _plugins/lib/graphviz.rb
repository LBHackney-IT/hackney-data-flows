require 'open3'

module GraphViz
  def self.generateDot(systems)
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
  end
  
  def self.dot2SVG(graphData)
    output = ''
    Open3.popen2("dot -Tsvg") {|i,o,t|
      i.print graphData
      i.close
      output = o.read
    }
    output
  end
  
  def self.generateSingleGraph(system)
    subsystems = system.dependencies
    dot2SVG(generateDot(subsystems))
  end
  
  def self.generateFullGraph(systems)
    dot2SVG(generateDot(systems))
  end

  def self.systemNodeName(system, options={})
    if system.entities.length > 0
      "#{system.id} [URL=\"/hackney-data-flows/systems/#{system.id}\" label=\"{#{system.name} | {#{system.entities.map{ |e| entityNodeName(e) }.join('|')}}}\"];"
    else
      "#{system.id} [URL=\"/hackney-data-flows/systems/#{system.id}\" label=\"#{system.name}\"];"
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
  
  def self.diagraph &block
    return %|digraph G {\nnode [shape=record];\ngraph [pad="0.5", ranksep="5", fontname="helvetica"];\nnode [fontname = "helvetica"];\nrankdir=RL;\n#{block.call}\n}|
  end

  def cluster &block
  
  end
end
