# encoding: utf-8
module Mysql2
  class Result
    def each_hash(&block)
      each(:as => :hash, &block)
    end
    
    def fetch_hash
      each(:as => :hash).first
    end
  end
end