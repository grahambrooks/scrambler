module Scrambler
  class Workspace
    attr_accessor :workspace_path

    def initialize(workspace_path)
      puts "Workspace path #{workspace_path}"
      self.workspace_path = workspace_path
    end

    def site_metrics_path
      File.join(workspace_path, "site-metrics.yml")
    end

    def audit_file_pattern
      File.join(workspace_path, "*.audit.csv")
    end

    def audit_file_path(project_name)
      File.join(workspace_path, project_name + ".audit.csv")
    end

    def audit_file_log_path(project_name)
      File.join(workspace_path, project_name + ".audit.csv.log")
    end

    def project_fetch_log_path(project_name)
      File.join(workspace_path, project_name + ".fetch.log")
    end

    def project_path(project_name)
      File.join(workspace_path, project_name)
    end
  end
end
