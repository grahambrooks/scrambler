module Paths
  def site_metrics_path
    File.join(@workspace, "site-metrics.yml")
  end

  def audit_file_pattern
    File.join(@workspace, "*.audit.csv")
  end

  def audit_file_path(project_name)
    File.join(@workspace, project_name + ".audit.csv")
  end

  def audit_file_log_path(project_name)
    File.join(@workspace, project_name + ".audit.csv.log")
  end

  def project_fetch_log_path(project_name)
    File.join(@workspace, project_name + ".fetch.log")
  end

  def project_path(project_name)
    File.join(@workspace, project_name)
  end
end