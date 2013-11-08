class CreateSysTempTexts < ActiveRecord::Migration
  def change
    create_table :sys_temp_texts do |t|
      t.text :content

      t.timestamps
    end
  end
end
