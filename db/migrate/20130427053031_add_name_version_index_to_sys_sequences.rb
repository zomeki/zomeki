class AddNameVersionIndexToSysSequences < ActiveRecord::Migration
  def up
    remove_index :sys_sequences, :name => :name
    add_index :sys_sequences, [:name, :version], :unique => true
  end

  def down
    remove_index :sys_sequences, [:name, :version]
    add_index :sys_sequences, [:name, :version], :name => :name
  end
end
