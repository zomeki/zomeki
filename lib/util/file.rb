class Util::File
  def self.put(path, options ={})
    if options[:mkdir] == true
      dir = ::File.dirname(path)
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
    end
    if options[:data]
      begin
        f = File.open(path, "w")
        begin
          f.flock(File::LOCK_EX) if options[:use_lock] != false
          f.write(options[:data] ? options[:data].force_encoding('utf-8') : '')
          f.flock(File::LOCK_UN) if options[:use_lock] != false
        ensure
          f.close
        end
      end
    elsif options[:src]
      return false unless FileTest.exist?(options[:src])
      FileUtils.cp options[:src], path
    end
    return true
  end
end