require 'spec_helper'
require 'scrambler/git_repo'

module Scrambler
  describe GitRepo do
    it "parses log entries" do
      repo = GitRepo.new(nil)
      log_text = <<EOD
f8856dc7183b1cf9ea19c53c52ef80b21d8fd1df|Rich Hickey|2012-05-04 20:49:08 -0400|better vector iterators
f416abb2abe12b7464469d06ecf4f712fdc395ec|Rich Hickey|2012-05-02 07:22:16 -0400|removed core.reduce for the moment due to literal and figurative backwardness - will revisit with fork/join in play.
4a22e3a44df48ea0d37dd034bc3f6cb3092117a9|Rich Hickey|2012-04-30 16:57:41 -0400|reduce can be terminated via (reduced x), first cut at reduce lib
96e8596cfdd29a2bb245d958683ee5fc1353b87a|Rich Hickey|2012-04-30 16:50:49 -0400|reduce can be terminated via (reduced x), first cut at reduce lib
EOD
      entries = repo.parse_log(log_text)

      entries.size.should be(4)

      entries[0][:sha].should == 'f8856dc7183b1cf9ea19c53c52ef80b21d8fd1df'
      entries[0][:author].should == 'Rich Hickey'
      entries[0][:date].should == Date.parse('2012-05-04 20:49:08 -0400')
      entries[0][:comment].should == 'better vector iterators'
    end

    it "retrieves log entries from repo" do
      repo = GitRepo.new(".")

      entries = repo.log_entries

      entries.size.should > 0
    end

    it "iterates commit entries" do
      repo = GitRepo.new(".")

      entries = repo.each_commit do |commit|
        commit[:sha].should_not == nil
        commit[:author].should_not == nil
        commit[:date].should_not == nil
        commit[:comment].should_not == nil
      end
    end
  end
end
