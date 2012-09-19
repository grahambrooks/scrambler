module Scrambler
  class GitRepo
    def initialize(path)
      @path = path
    end

    def parse_log(log_text)
      entries = []
      log_text.each_line do |line|
        elements = line.strip.split(/\|/)
        entries << {
            :sha => elements[0],
            :author => elements[1],
            :date => Date.parse(elements[2]),
            :comment => elements[3]
        }
      end
      entries
    end
  end
end