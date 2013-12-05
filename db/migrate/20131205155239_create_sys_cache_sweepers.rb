class CreateSysCacheSweepers < ActiveRecord::Migration
  def change
    create_table "sys_cache_sweepers", :force => true do |t|
      t.string   "state",      :limit => 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "model"
      t.text     "uri"
      t.text     "options"
    end

    add_index "sys_cache_sweepers", ["model", "uri"], :name => "model", :length => {"model"=>20, "uri"=>30}
  end
end
