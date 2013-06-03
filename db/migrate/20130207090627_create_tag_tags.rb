class CreateTagTags < ActiveRecord::Migration
  def change
    create_table :tag_tags do |t|
      t.references :content

      t.text     :word
      t.datetime :last_tagged_at

      t.timestamps
    end
    add_index :tag_tags, :content_id
  end
end
