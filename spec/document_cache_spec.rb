require 'spec_helper'
require 'scrambler/document_cache'

module Scrambler
  describe DocumentCache do
    it "stores documents" do
      cache = DocumentCache.new('test')

      cache.save({ :sha => 'Some unique key value', :data => [ 'some collection of data']})

      doc = cache.find(:sha => 'Some unique key value')
      doc['sha'].should == 'Some unique key value'
    end
  end
end
