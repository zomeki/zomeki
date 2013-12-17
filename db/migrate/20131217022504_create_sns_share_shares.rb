class CreateSnsShareShares < ActiveRecord::Migration
  def change
    create_table :sns_share_shares do |t|
      t.belongs_to :sharable, polymorphic: true
      t.belongs_to :account

      t.timestamps
    end
    add_index :sns_share_shares, [:sharable_type, :sharable_id]
  end
end
