# encoding: utf-8
module GpTemplate::Model::Rel::Template
  def self.included(mod)
    mod.serialize :template_values
    mod.belongs_to :template, :class_name => 'GpTemplate::Template'
    mod.after_initialize :set_template_defaults
    mod.before_save :make_template_file_contents_path_relative
  end

  def set_template_defaults
    if self.template_id.nil?
      self.template_id = content.default_template.id if self.has_attribute?(:template_id) && content && content.default_template
    end
    self.template_values ||= {} if self.has_attribute?(:template_values)
  end

  def make_template_file_contents_path_relative
    return unless template

    template.items.each do |item|
      if item.item_type == 'rich_text'
        self.template_values[item.name] = self.template_values[item.name].to_s.gsub(%r|"[^"]*?/(file_contents/)|, '"\1')
      end
    end
  end
end
