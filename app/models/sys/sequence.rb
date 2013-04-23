class Sys::Sequence < ActiveRecord::Base
  set_table_name 'sys_sequences'

  scope :versioned, lambda {|v| where(version: v) }
end
