require "scrambler/version"
require "scrambler/code_scramble"
require "scrambler/site_metrics"
require "scrambler/git_repo"
require "paths"
require 'fileutils'
require 'yaml'

module Scrambler
  SCRAMBLER_FILE = "scrambler.yml"
  extend Paths

  def self.exec!(args)
    puts "Scrambler #{VERSION}"

    if File.exists? SCRAMBLER_FILE
      config       = load_config()
      @workspace   = config["workspace"]
      cs           = CodeScramble.new(config)
      repositories = cs.repositories

      repositories.each do |repository|
        fork {
          generate_repository_metrics(repository)
        }
      end

      Process.waitall

      compile_metrics(config)

      cs.post_results
    else
      puts "Could not find scrambler file #{SCRAMBLER_FILE}"
    end
  end

  def self.generate_repository_metrics(repository)
    p repository
    project_name = project_name(repository)
    path = project_path(project_name)

    puts "Processing project workspace #{path} of type #{repository["type"]}"

    unless File.exist? path
      clone_repo(path, repository)
    end

    puts "Updating repository #{path}"
    update_repo(path, project_name, repository)

    repo = new GitRepo(path)

    repo.each_commit do |commit|

    end

    puts "Running CLOC"
    shell "cloc.pl --csv --report-file=#{audit_file_path(project_name)} #{path} > #{audit_file_log_path(project_name)}"
  end

  def self.update_repo(path, project_name, repository)
    case repository["uri_type"]
      when "subversion"
        shell "cd #{path};git svn fetch > #{project_fetch_log_path(project_name)}"
      when "git"
        shell "cd #{path};git pull > #{project_fetch_log_path(project_name)}"
    end
  end

  def self.clone_repo(path, repository)
    puts "Cloneing #{repository["uri"]}"
    FileUtils.mkdir(path)

    case repository["uri_type"]
      when "subversion"
        print `cd #{path};svn2git #{repository["uri"]}`
      when "git"
        print `cd #{path};git clone #{repository["uri"]} .`
    end
  end

  def self.project_name(repository)
    repository["name"].downcase.gsub(" ", "_")
  end

  def self.compile_metrics(config)
    site_metrics = SiteMetrics.new(config)

    site_metrics.compile
  end

  def self.shell(cmd)
    puts cmd
    `#{cmd}`
  end

  def self.load_config
    config = YAML.load_file SCRAMBLER_FILE
    fail "Missing workspace configuration in #{SCRAMBLER_FILE}" unless config["workspace"]
    fail "Missing site configuration in #{SCRAMBLER_FILE}" unless config["site"]

    puts "Processing projects from #{config["site"]} in #{config["workspace"]}"
    config
  end
end
