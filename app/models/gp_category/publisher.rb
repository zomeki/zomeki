class GpCategory::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  attr_accessible :category_id

  belongs_to :category

  validates :category_id, :presence => true, :uniqueness => true

  def self.register_category(category)
    category_id = category.kind_of?(GpCategory::Category) ? category.id : category.to_i
    self.where(category_id: category_id).first_or_create if category_id > 0
  end

  def self.register_categories(categories)
    categories.each{|c| self.register_category(c) }
  end

  def self.publish_categories
    category_ids = {}
    self.all.each do |publisher|
      unless (c = publisher.category)
        publisher.destroy
        next
      end
      category_ids[c.content.id] ||= {}
      category_ids[c.content.id][c.category_type.id] ||= []
      category_ids[c.content.id][c.category_type.id] << c.id
    end

    category_ids.each do |key, value|
      value.each do |k, v|
        ids = v.map{|c| "target_child_id[]=#{c}" }.join('&')
        script_params = "target_module=gp_category&target_content_id[]=#{key}&target_id[]=#{k}&#{ids}"
        self.where(category_id: v).destroy_all
        ::Script.run("cms/script/nodes/publish?all=all&#{script_params}", force: true)
      end
    end
  end
end
