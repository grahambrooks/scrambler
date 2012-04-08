require "scrambler/version"
require "scrambler/code_scramble"
require "scrambler/site_metrics"
require 'fileutils'
require 'yaml'

module Scrambler
  SCRAMBLER_FILE = "scrambler.yml"

  def self.exec!(args)
    puts "Scrambler #{VERSION}"

    if File.exists? SCRAMBLER_FILE
      config = YAML.load_file SCRAMBLER_FILE
      fail "Missing workspace configuration in #{SCRAMBLER_FILE}" unless config["workspace"]
      fail "Missing site configuration in #{SCRAMBLER_FILE}" unless config["site"]

      puts "Processing projects from #{config["site"]} in #{config["workspace"]}"

      cs           = CodeScramble.new(config)
      repositories = cs.repositories

      p repositories

      repositories.each do |repository|
        fork {
          project_name = repository["name"].downcase.gsub(" ", "_")
          project_path = File.join(config["workspace"], project_name)

          puts "Processing project workspace #{project_path}"

          unless File.exist? project_path
            puts "Cloneing #{repository["uri"]}"
            FileUtils.mkdir(project_path)

            print `cd #{project_path};svn2git #{repository["uri"]}`
          end
          puts "Updating repository #{project_path}"
          print `cd #{project_path};git svn fetch`

          print `pwd`

          print `~/bin/cloc.pl --csv --report-file=#{File.join(config['workspace'], project_name + ".audit.csv")} #{project_path}`
        }
      end

      Process.waitall

      site_metrics = SiteMetrics.new(config)

      site_metrics.compile

    else
      puts "Could not find scrambler file #{SCRAMBLER_FILE}"
    end
  end
end
