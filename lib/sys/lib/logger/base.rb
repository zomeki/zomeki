class Sys::Lib::Logger::Base
  def initialize(name, options = {})
    if name.class == Hash
      @name    = nil
      @options = name
    else
      @name    = name.to_s
      @options = options
    end
    
    @time = Time.now
    @options[:time]    ||= @time.to_s(:db)
    @options[:type]    ||= 'Script'
    @options[:agent]   ||= 'Unknown'
    @options[:message] ||= 'Started.'
    
    @common_file = log_file(:messages)
    if @common_file
      dir = ::File.dirname(@common_file)
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
    end
    
    @target_file = @name ? log_file(@name) : nil
    if @target_file
      dir = ::File.dirname(@target_file)
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
    end
    
    message = common_message(@options[:message])
    puts(message, :file => @common_file)
    puts(message)
  end
  
  def log_file(name)
    "#{Rails.root}/log/#{name}.log"
  end
  
  def common_message(message)
    message = '"' + message.to_s.gsub('"', '""').gsub(/\r\n|\r|\n/, ' ') + '"'
    "#{@options[:time]}, #{@options[:type]}, #{@options[:agent]}, #{message}"
  end
  
  def puts(message, options = {})
    file = options[:file] || @target_file
    return false unless file
    f = ::File.open(file, 'a')
    f.flock(File::LOCK_EX)
    f.puts message
    f.flock(::File::LOCK_UN)
    f.close
  end
  
  def close(message = 'Finished.')
    message = common_message(message)
    puts(message, :file => @common_file)
    puts(message)
  end
end