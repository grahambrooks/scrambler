require 'json'
require 'paths'
require 'net/http'

module Scrambler
  class CodeScramble
    include Paths

    def initialize(config)
      @workspace            = config["workspace"] || fail("Workspace folder required")
      @home                 = config['site'] || fail("Site must be specified")
      site_map              = get_json "#{@home}?format=json"
      @repositories_uri     = @home + site_map["repositories"]
      @new_site_metrics_uri = @home + site_map["new_site_metric"]
    end

    def repositories()
      get_json @repositories_uri + "?format=json"
    end

    def get_json(uri)
      puts "Reading '#{uri}'"
      resp = Net::HTTP.get_response(URI.parse(uri))

      JSON.parse(resp.body)
    end

    def post_results
      yml = File.read(site_metrics_path)

      uri    = URI(@new_site_metrics_uri + "?format=json")
      params = {'date' => DateTime.now, 'data' => yml}
      params = Hash[params.map { |key, value| ["site_metric[#{key}]", value] }]

      Net::HTTP::post_form(uri, params)
      res = Net::HTTP.post_form(uri, params)
      p res
    end
  end
end
