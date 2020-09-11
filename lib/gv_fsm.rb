#!/usr/bin/env ruby

require 'ruby-graphviz'
require 'erb'
require 'matrix'

require File.expand_path('../templates.rb', __FILE__)
require File.expand_path("../version.rb", __FILE__)

module GV_FSM
  class FSM
    attr_reader :states, :transitions, :dotfile, :prefix, :error
    attr_accessor :project_name, :description, :cname, :syslog, :ino
    include GV_FSM::Templates

    def initialize(filename = nil)
      @prefix = ""
      @syslog = true
      @ino = false
      @error = nil
      @matrix = nil
      @nodemap = {}
      parse(filename) if filename
    end

    def prefix=(v)
      @prefix = v + '_'
    end

    def parse(filename)
      raise ArgumentError, "File must be in .dot format" unless File.extname(filename) == ".dot"
      @cname = File.basename(filename, ".dot") unless (@cname and ! @cname.empty?)
      @dotfile = filename
      @states = []
      @transitions = []
      graph = GraphViz.parse(filename) do |g|
        if g.graph_count > 1 then
          @error = "Only one graph in the dot file is permitted"
          return nil
        end
        unless g.type == "digraph" then
          @error = "Graph is not directed"
          return nil
        end
        n = g.node_count
        if n == 0 then
          @error = "Graph is empty"
          return nil
        end
        @matrix = Matrix.zero(n, n)
        @description = g.name
        i = 0
        g.each_node do |id|
          n = g.get_node(id)
          if n[:label].source.empty? or
            (n[:label].source == id and !n[:label].source.match(/^do_/)) then
            label = "do_#{id}"
          else
            label = n[:label].source
          end
          @nodemap[id] = i
          i += 1
          @states << {id: id, function: @prefix+label}
        end
        g.each_edge do |e|
          @matrix[@nodemap[e.node_one], @nodemap[e.node_two]] += 1
          from = e.node_one
          to = e.node_two
          unless e[:label] then
            @transitions << {from: from, to: to, function: nil} 
            next
          end
          case e[:label].source
          when ""
            label = nil
          when /[#]/
            label = "#{from}_to_#{to}"
          else
            label = e[:label].source
          end
          @transitions << {from: from, to: to, function: label ? @prefix+label : nil}
        end
      end
      unless graph then 
        @error = "Parsing error"
        return nil
      end
      return graph
    end

    def state_functions_list
      @states.map {|s| s[:function]}
    end

    def states_list
      @states.map {|s| s[:id]}
    end

    def transition_functions_list
      lst = []
      @transitions.each do |t|
        if t[:function] and !lst.include? t[:function] then
          lst << (t[:function] or "NULL")
        end
      end
      return lst
    end

    def transitions_map
      idx = {}
      map = Array.new(@states.count)
      map.map! {|e| e = Array.new(@states.count, "NULL")}
      states_list.each_with_index {|s, i| idx[s] = i }
      @transitions.each do |t|
        map[idx[t[:from]]][idx[t[:to]]] = (t[:function] or "NULL")
      end
      map
    end

    def destinations
      dest = Hash[states_list.map {|x| [x, []]}]
      @transitions.each do |t|
        dest[t[:from]] = [] unless dest[t[:from]]
        dest[t[:from]] << t[:to]
      end
      return dest
    end

    def transitions_paths
      path = {}
      @transitions.each do |t|
        path[t[:function]] = [] unless path[t[:function]]
        path[t[:function]] << {from: t[:from], to: t[:to]}
      end
      return path
    end

    def generate_c(filename = @cname)
      ext = @ino ? "cpp" : "c"
      fname = "#{filename}.#{ext}"
      File.open(fname, "w") do |f|
        f.puts ERB.new(HEADER, 0, "<>").result(binding)
        f.puts ERB.new(CC, 0, "<>").result(binding)
      end
      return fname
    end

    def generate_h(filename = @cname)
      fname = "#{filename}.h"
      File.open(fname, "w") do |f|
        f.puts ERB.new(HEADER, 0, "<>").result(binding)
        f.puts ERB.new(HH, 0, "<>").result(binding)
      end
      return fname
    end

    def topology
      res = {matrix: @matrix}
      # rows have the number of froms, columns the number of tos
      res[:froms] = @matrix.row_vectors.map {|v| v.sum }
      res[:tos] = @matrix.column_vectors.map {|v| v.sum }
      res[:sinks] = res[:froms].each_index.select {|i| res[:froms][i] == 0}.map {|i| @nodemap.keys[i]}
      res[:sources] = res[:tos].each_index.select {|i| res[:tos][i] == 0}.map {|i| @nodemap.keys[i]}
      return res
    end

  end

end