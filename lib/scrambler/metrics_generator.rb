
module Scrambler
  class MetricsGenerator
    attr_accessor :config
    attr_accessor :workspace
    attr_accessor :shell

    def initialize(config)
      self.config = config
      self.workspace = Workspace.new(config["workspace"])
      self.shell = Shell.new
    end

    def generate_metrics(repository_spec)
      p repository_spec
      project_name = project_name(repository_spec)
      path = workspace.project_path(project_name)

      puts "Processing project workspace #{path} of type #{repository_spec["uri_type"]}"

      repo = Repository.new(workspace, shell)
      unless File.exist? path
        repo.clone(repository_spec, path)
      else
        repo.update(path, project_name, repository_spec)
      end

      puts "Running CLOC"
      shell.execute "cloc.pl --csv --report-file=#{workspace.audit_file_path(project_name)} #{path} > #{workspace.audit_file_log_path(project_name)}"

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

    def analyse_commit(sha, config, path, project_name)
      begin
        puts "Analysing #{project_name} commit: '#{sha}'"
        shell.execute "cd #{path};git checkout #{sha}"

        shell.execute "cloc.pl --csv --report-file=#{workspace.commit_audit_file_path(project_name, sha)} #{path} > #{workspace.commit_audit_file_path(project_name, sha)}"

        site_metrics = SiteMetrics.new(config)

        metrics = {:sha => sha, :cloc => site_metrics.parse_commit_csv(CSV.open(workspace.commit_audit_file_path(project_name, sha)))}
        yield metrics

        File.delete(workspace.commit_audit_file_path(project_name, sha))
      rescue Exception => e
        puts "Error processing commit #{sha}"
      end
    end

    def project_name(repository)
      repository["name"].downcase.gsub(" ", "_")
    end

    def compile_metrics(config)
      begin
        site_metrics = SiteMetrics.new(config)

        site_metrics.compile
      rescue Exception => e
        puts "Error processing site metrics #{e.message}"
      end
    end
  end
end
