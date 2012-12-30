module Scrambler
  class Shell
    def self.execute(cmd)
      puts cmd
      print `#{cmd}`
    end

    def execute(cmd)
      puts cmd
      print `#{cmd}`
    end
  end
end