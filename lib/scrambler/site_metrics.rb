require 'csv'

module Scrambler
  class SiteMetrics
    def initialize(config)
      @workspace = config["workspace"] || fail("Workspace folder required")
    end

    def parse_csv(csv, metrics)
      csv.each do |row|
        if row[0] =~ /^[0-9]+$/
          if metrics[row[1]]
            metrics[row[1]][:files]   += row[0].to_i
            metrics[row[1]][:blank]   += row[2].to_i
            metrics[row[1]][:comment] += row[3].to_i
            metrics[row[1]][:code]    += row[4].to_i
          else
            metrics[row[1]] = {:files   => row[0].to_i,
                               :blank   => row[2].to_i,
                               :comment => row[3].to_i,
                               :code    => row[4].to_i}
          end
        end
      end
    end

    def compile
      metrics = {}
      Dir.glob File.join(@workspace, "*.audit.csv") do |audit_file|
        parse_csv(CSV.open(audit_file), metrics)
      end


      File.open(File.join(@workspace, "site-metrics.yml"), "w") do |f|
        f.print metrics.to_yaml
      end
    end
  end
end
