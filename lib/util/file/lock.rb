class Util::File::Lock
  @locked = {}
  
  def self.lock_by_name(name)
    dir  = "#{Rails.root}/tmp/lock"
    FileUtils.mkdir(dir) unless ::File.exists?(dir)
    return false unless f = ::File.open(dir + '/_' + name, 'w')
    return false unless f.flock(File::LOCK_EX)
    return @locked[name] = f
  end
  
  def self.unlock_by_name(name)
    @locked[name].flock(File::LOCK_UN)
    @locked[name].close
    @locked.delete(name)
    if FileTest.exist?("#{Rails.root}/tmp/lock/_#{name}")
      ::File.unlink("#{Rails.root}/tmp/lock/_#{name}")
    end
  end
end