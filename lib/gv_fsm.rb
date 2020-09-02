#!/usr/bin/env ruby

require 'ruby-graphviz'
require 'erb'

require File.expand_path('../templates.rb', __FILE__)
require File.expand_path("../version.rb", __FILE__)

module GV_FSM
  class FSM
    attr_reader :states, :transitions, :dotfile, :prefix
    attr_accessor :project_name, :description, :cname, :syslog, :ino
    include GV_FSM::Templates

    def initialize(filename = nil)
      @prefix = ""
      @syslog = true
      @ino = false
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
      GraphViz.parse(filename) do |g|
        g.each_node do |id|
          n = g.get_node(id)
          if n[:label].source.empty? or
            (n[:label].source == id and !n[:label].source.match(/^do_/)) then
            label = "do_#{id}"
          else
            label = n[:label].source
          end
          @states << {id: id, function: @prefix+label}
        end
        g.each_edge do |e|
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
      File.open("#{filename}.c", "w") do |f|
        f.puts ERB.new(HEADER, 0, "<>").result(binding)
        f.puts ERB.new(CC, 0, "<>").result(binding)
      end
    end

    def generate_h(filename = @cname)
      File.open("#{filename}.h", "w") do |f|
        f.puts ERB.new(HEADER, 0, "<>").result(binding)
        f.puts ERB.new(HH, 0, "<>").result(binding)
      end
    end

    def generate_ino(filename=@cname)
      @syslog = false
      File.open("#{filename}.ino", "w") do |f|
        f.puts ERB.new(HEADER, 0, "<>").result(binding)
        f.puts ERB.new(HH, 0, "<>").result(binding)
        f.puts ERB.new(CC, 0, "<>").result(binding)
      end
    end
  end

end