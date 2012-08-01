class Script
  cattr_reader :lock_key
  cattr_reader :options
  
  def self.run(path, options = nil)
    ENV['INPUTRC'] ||= "/etc/inputrc"
    
    @@lock_key = 'script_' + path.gsub(/\W/, "_")
    @@options  = options
    
    if self.lock == false
      puts "[ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} ]: Script.run('#{path}') already running."
      return true
    end
    
    begin
      puts "[ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} ]: Script.run('#{path}') started."
      
      app = ActionController::Integration::Session.new(Rails.application)
      app.get "/_script/sys/run/#{path}"
      
      puts "[ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} ]: Script.run('#{path}') finished."
    rescue => e
      puts e.backtrace.join("\n") + "\n\n"
      puts "ScriptError: #{e}"
    end
    self.unlock
  end
  
protected
  def self.lock(lock_key = @@lock_key)
    file = "#{Rails.root}/tmp/lock/#{lock_key}"
    if ::File.exist?(file)
      locked = ::File.stat(file).mtime.to_i
      return false if Time.now.to_i < locked + (60*60)
      unlock(lock_key)
    end
    ::File.open(file, 'w')
    return true
  rescue
    return false
  end
  
  def self.unlock(lock_key = @@lock_key)
    file = "#{Rails.root}/tmp/lock/#{lock_key}"
    ::File.unlink(file)
  end
  
  def self.keep_lock(lock_key = @@lock_key)
    file = "#{Rails.root}/tmp/lock/#{lock_key}"
    FileUtils.touch(file) rescue nil
  end
end