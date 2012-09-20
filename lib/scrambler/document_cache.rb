require 'mongo'

module Scrambler
  class DocumentCache
    def initialize(collection_name)
      @connection = Mongo::Connection.new("localhost")
      @db = @connection.db("scrambler-cache")
      @collection = @db.collection(collection_name)
    end

    def save(document)
      @collection.insert(document)
    end

    def find(keys)
      @collection.find_one(keys)
    end
  end
end