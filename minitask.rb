#! /usr/bin/env ruby

require 'optparse'
require 'json'
require 'open-uri'

class MiniTaskOptions

  def self.parse(args)
    options = Hash.new
    options[:output] = :text

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: minitask [options]"

      opts.separator ""
      opts.separator "Commands:"

      opts.on("-l", "--list", "List all tasks") do
        options[:command] = :list
      end

      opts.on("-a", "--add TASK", "Adds a new task") do |task|
        options[:command] = :add
        options[:task] = task
      end

      opts.on("-t", "--take", "Takes the next task") do
        options[:command] = :take
      end

      opts.on("-r", "--random", "Takes a random task") do
        options[:command] = :random
      end

      opts.on("-d", "--defer [TASK]", "Defers the task for 1 month") do |task|
        options[:command] = :defer
        options[:task] = task
      end

      opts.on("-c", "--complete [TASK]", "Completes the task") do |task|
        options[:command] = :complete
        options[:task] = task
      end

      opts.on("--update", "Updates this app from master") do
        opts[:command] = :update
      end

      opts.separator ""
      opts.separator "Modiers:"

      opts.on("-e", "--effort AMOUNT", [:small, :medium, :large], "Scope command to amount of effort") do |effort|
        options[:effort] = :"#{effort}"
      end

      opts.on("--json", "JSON output") do
        options[:output] = :json
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("--version", "Show version") do
        puts "MiniTask version #{MiniTask::VERSION} #{File.absolute_path(__FILE__)}"
        exit
      end

    end

    opt_parser.parse!(args)
    options
  end

end

class MiniTask

  VERSION = "1.0"

  attr_reader :options

  def initialize options
    @options = options
  end

  def self.run(options)
    mini_task = new(options)
    mini_task.send(options[:command])
  end

  def list
    with_data do
      print_tasks tasks
    end
  end

  def add
    with_data do
      tasks << {'title' => options[:task]}
      print_success "Task '#{options[:task]}' added"
    end
  end

  def take
    with_data do
      task = tasks.first
      print_tasks task
    end
  end

  def random
    with_data do
      task = tasks.sample
      print_tasks task
    end
  end

  def complete task = nil
    with_data do
    end
  end

  def update
    # curl code from github
    # do opposite of data saving

    update_code = ""
    update_download = open("")
    while (line = update_download.gets)
      break if line.chomp == "__END__"
      update_code << line
    end

    read_file = File.new(absolute_path, "r")
    file_contents = ""
    while (line = read_file.gets) do
      file_contents << line
      break if line.chomp == "__END__"
    end
    read_file.close

    file_contents << @data.to_json

    write_file = File.open(absolute_path, "w")
    write_file.puts file_contents
    write_file.close
  end

  private

  def config
    @data['config']
  end

  def tasks
    @data['tasks']
  end

  def with_data &block
    load_data
    block.call
    save_data
  end

  def load_data
    @data = JSON.parse(DATA.read)
  rescue
    @data = {
      'config' => {},
      'tasks' => []
    }
  end

  def save_data
    read_file = File.new(absolute_path, "r")
    file_contents = ""
    while (line = read_file.gets) do
      file_contents << line
      break if line.chomp == "__END__"
    end
    read_file.close

    file_contents << @data.to_json

    write_file = File.open(absolute_path, "w")
    write_file.puts file_contents
    write_file.close
  end

  def absolute_path
   File.absolute_path(__FILE__) 
  end

  def print_text text
    @output ||= Array.new
  end

  def print_success text
    case options[:output]
    when :text
      puts "✓ #{text}"
    when :json
      puts JSON.dump({success: text})
    end
  end

  def print_tasks tasks
    case options[:output]
    when :text
      puts tasks.map{|t| t.title}.join("\r\n")
    when :json
      puts JSON.dump(tasks)
    end
  end

end

MiniTask.run(MiniTaskOptions.parse(ARGV))

__END__
{"config":{},"tasks":[{"title":"Do the dishes"},{"title":"record the TV program"}]}
