# encoding: utf-8
require 'digest/md5'

class Util::Sequencer
  def self.next_id(name, options = {})
    name    = name.to_s
    version = options[:version] || 0

    lock = Util::File::Lock.lock("#{name}_#{version}")
    raise 'error: sequencer locked' unless lock

    seq = nil

    Sys::Sequence.transaction do
      Sys::Sequence.uncached do
        if seq = Sys::Sequence.versioned(version.to_s).find_by_name(name)
          seq.update_column(:value, seq.value + 1)
        else
          seq = Sys::Sequence.create(name: name, version: version, value: 1)
        end
      end
    end

    lock.unlock

    if options[:md5]
      Digest::MD5.new.update(seq.value.to_s)
    else
      seq.value
    end
  end
end
