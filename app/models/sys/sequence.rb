class Sys::Sequence < ActiveRecord::Base
  set_table_name "sys_sequences"
  
  def self.versioned(version)
    self.where :version => version
  end
end
