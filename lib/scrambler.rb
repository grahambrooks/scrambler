require "scrambler/version"
require "scrambler/code_scramble"
require "scrambler/site_metrics"
require "scrambler/git_repo"
require "scrambler/document_cache"
require "scrambler/workspace"
require "scrambler/shell"
require "scrambler/repository"
require "scrambler/metrics_generator"
require "paths"
require "csv"
require 'fileutils'
require 'yaml'

module Scrambler
  SCRAMBLER_FILE = "scrambler.yml"
  extend Paths

  def self.exec!(args)
    puts "Scrambler #{VERSION}"

    if File.exists? SCRAMBLER_FILE
      config = load_config()
      @workspace = config["workspace"]
      cs = CodeScramble.new(config)
      repositories = cs.repositories

      generator = MetricsGenerator.new(config)

      repositories.each do |repository|
#        fork {
        generator.generate_metrics(repository)
        generate_repository_metrics(config, repository)
#        }
      end

#      Process.waitall

      compile_metrics(config)

      cs.post_results
    else
      puts "Could not find scrambler file #{SCRAMBLER_FILE}"
    end
  end

  def self.generate_repository_metrics(config, repository)
    p repository
    project_name = project_name(repository)
    path = project_path(project_name)

    puts "Processing project workspace #{path} of type #{repository["uri_type"]}"

    unless File.exist? path
      clone_repo(path, repository)
    end

    update_repo(path, project_name, repository)

    puts "Running CLOC"
    shell "cloc.pl --csv --report-file=#{audit_file_path(project_name)} #{path} > #{audit_file_log_path(project_name)}"

    repo = GitRepo.new(path)

    cache = DocumentCache.new('prod')

    repo.each_commit do |commit|
      if !cache.contains_sha? commit[:sha]
        analyse_commit(commit[:sha], config, path, project_name) do |metrics|
          cache.save(metrics)
        end
      end
    end
  end

  def self.analyse_commit(sha, config, path, project_name)
    begin
      puts "Analysing #{project_name} commit: '#{sha}'"
      shell "cd #{path};git checkout #{sha}"
      shell "cloc.pl --csv --report-file=#{commit_audit_file_path(project_name, sha)} #{path} > #{commit_audit_file_path(project_name, sha)}"

      site_metrics = SiteMetrics.new(config)

      metrics = {:sha => sha, :cloc => site_metrics.parse_commit_csv(CSV.open(commit_audit_file_path(project_name, sha)))}
      yield metrics
      File.delete(commit_audit_file_path(project_name, sha))
    rescue Exception => e
      puts "Error processing commit #{sha}"
    end
  end

  def self.update_repo(path, project_name, repository)
    puts "Updating repository #{path}"

    case repository["uri_type"]
      when "subversion"
        shell "cd #{path};git svn fetch > #{project_fetch_log_path(project_name)}"
      when "git"
        shell "cd #{path};git pull > #{project_fetch_log_path(project_name)}"
    end
  end

  def self.clone_repo(path, repository)
    puts "Cloning #{repository["uri"]}"
    FileUtils.mkdir(path)

    case repository["uri_type"]
      when "subversion"
        shell "cd #{path};svn2git #{repository["uri"]}"
      when "git"
        shell "cd #{path};git clone #{repository["uri"]} ."
    end
  end

  def self.project_name(repository)
    repository["name"].downcase.gsub(" ", "_")
  end

  def self.compile_metrics(config)
    begin
    site_metrics = SiteMetrics.new(config)

    site_metrics.compile
    rescue Exception => e
      puts "Error processing site metrics #{e.message}"
      end
  end

  def self.shell(cmd)
    puts cmd
    print `#{cmd}`
  end

  def self.load_config
    config = YAML.load_file SCRAMBLER_FILE
    fail "Missing workspace configuration in #{SCRAMBLER_FILE}" unless config["workspace"]
    fail "Missing site configuration in #{SCRAMBLER_FILE}" unless config["site"]

    puts "Processing projects from #{config["site"]} in #{config["workspace"]}"
    config
  end
end
