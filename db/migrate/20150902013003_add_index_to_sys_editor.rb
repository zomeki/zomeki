class AddIndexToSysEditor < ActiveRecord::Migration
  def change
    add_index "sys_editors", ["parent_unid", "last_is"], :name => "index_sys_editors_on_last_is"
  end
end
