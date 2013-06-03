# encoding: utf-8
class Cms::ContentSetting < ActiveRecord::Base
  include Sys::Model::Base
  
  attr_accessor :form_type, :options
  
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Cms::Content'

  validates_presence_of :content_id, :name
  
  def self.set_config(id, params = {})
    @@configs ||= {}
    @@configs[self] ||= []
    @@configs[self] << params.merge(:id => id)
  end
  
  def self.configs(content)
    configs = []
    if defined?(@@configs)
      @@configs[self].each {|c| configs << config(content, c[:id])}
    end
    configs
  end
  
  def self.config(content, name)
    cond = {:content_id => content.id, :name => name.to_s}
    self.find(:first, :conditions => cond) || self.new(cond)
  end
  
  def editable?
    content.editable?
  end
  
  def config
    return @config if @config
    @@configs[self.class].each {|c| return @config = c if c[:id].to_s == name.to_s}
    nil
  end
  
  def config_name
    config ? config[:name] : nil
  end
  
  def config_options
    return config[:options].call if config[:options].is_a?(Proc)
    config[:options] ? config[:options].collect {|e| [e[0], e[1].to_s] } : nil
  end
  
  def upper_text
    config[:upper_text] ? config[:upper_text] : nil
  end
  
  def lower_text
    config[:lower_text] ? config[:lower_text] : nil
  end
  
  def value_name
    opts = if config[:options].is_a?(Proc)
             config[:options].call
           else
             config[:options]
           end
    if opts
      case config[:form_type]
      when :check_boxes
        YAML.load(value.presence || '[]').map{|v| opts.detect{|o| o.last == v }.try(:first) }.compact.join(', ')
      when :multiple_select
        ids = YAML.load(value.presence || '[]')
        config_options.where(id: ids).map(&:name).join(', ')
      else
        opts.detect{|o| o.last.to_s == value.to_s }.try(:first)
      end
    else
      value.presence
    end
  end
  
  def form_type
    return config[:form_type] if config[:form_type]
    config_options ? :select : :string
  end
  
end
