class Sys::Sequence < ActiveRecord::Base
  set_table_name 'sys_sequences'

  scope :versioned, lambda {|v| where(version: v) }

  validates :version, :uniqueness => {:scope => :name}

  def self.next(name, version)
    self.transaction do
      seq = self.lock.find_or_create_by_name_and_version(name, version)
      seq.increment!(:value)
      return seq
    end
  end
end
