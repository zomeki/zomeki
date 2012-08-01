class AddResCreationToPublicBbsThreads < ActiveRecord::Migration
  def change
    add_column :public_bbs_threads, :res_creation, :string
  end
end
