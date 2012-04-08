require 'json'
require 'net/http'

module Scrambler
  class CodeScramble
    def initialize(config)
      @home             = config['site']
      sitemap           = get_json "#{@home}?format=json"
      @repositories_uri = @home + sitemap["repositories"]
    end

    def repositories()
      get_json @repositories_uri + "?format=json"
    end

    def get_json(uri)
      puts "Reading '#{uri}'"
      resp = Net::HTTP.get_response(URI.parse(uri))

      JSON.parse(resp.body)
    end
  end
end
