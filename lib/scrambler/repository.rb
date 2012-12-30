module Scrambler
  class Repository
    attr_accessor :workspace
    attr_accessor :shell

    def initialize(workspace, shell)
      self.workspace = workspace
      self.shell = shell
    end

    def clone(repository_spec, path)
      puts "Cloning #{repository_spec["uri"]} to #{path}"
      FileUtils.mkdir(path)

      case repository_spec["uri_type"]
        when "subversion"
          shell.execute "cd #{path};svn2git #{repository_spec["uri"]}"
        when "git"
          shell.execute "cd #{path};git clone #{repository_spec["uri"]} ."
      end
    end

    def update(path, project_name, repository)
      puts "Updating repository #{path}"

      case repository["uri_type"]
        when "subversion"
          shell.execute "cd #{path};git svn fetch > #{workspace.project_fetch_log_path(project_name)}"
        when "git"
          shell.execute "cd #{path};git checkout master > #{workspace.project_fetch_log_path(project_name)}"
          shell.execute "cd #{path};git pull > #{workspace.project_fetch_log_path(project_name)}"
      end
    end

  end
end