# encoding: utf-8
class Util::Sequencer
  def self.next_id(name, options = {})
    name    = name.to_s
    version = options[:version] || 0
    
    lock = name.to_s + '_' + version.to_s
    unless Util::File::Lock.lock_by_name(lock)
      raise "error: sequencer locked"
    end
    
    if seq = Sys::Sequence.versioned(version.to_s).find_by_name(name)
      seq.value += 1
      seq.save
    else
      seq = Sys::Sequence.new
      seq.name = name
      seq.version = version
      seq.value = 1
      seq.save
    end
    
    Util::File::Lock.unlock_by_name(lock)
    
    if options[:md5]
      require 'digest/md5'
      return Digest::MD5.new.update(seq.value.to_s)
    end
    return seq.value
  end
end