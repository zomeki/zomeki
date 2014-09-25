# encoding: utf-8
class Sys::Model::Base::Setting < ActiveRecord::Base
  self.table_name = "sys_settings"
  
  def self.set_config(id, params = {})
    @@configs ||= {}
    @@configs[self] ||= []
    @@configs[self] << params.merge(:id => id)
  end
  
  def self.configs
    @@configs[self].collect {|c| config(c[:id])}
  end
  
  def self.config(name)
    cond = {:name => name.to_s}
    self.find(:first, :conditions => cond) || self.new(cond)
  end
  
  def self.value(name, default_value = nil)
    st = config(name)
    return nil unless st
    return st.value.blank? ? default_value || st.default_value : st.value
  end
  
  def editable?
    true
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
    config[:options] ? config[:options].collect {|e| [e[0], e[1].to_s] } : nil
  end
  
  def style
    config[:style] ? config[:style] : nil
  end
  
  def upper_text
    config[:upper_text] ? config[:upper_text] : nil
  end
  
  def lower_text
    config[:lower_text] ? config[:lower_text] : nil
  end
  
  def default_value
    config[:default] ? config[:default] : nil
  end
  
  def value_name
    if config[:options]
      config[:options].each {|c| return c[0] if c[1].to_s == value.to_s}
    else
      return value if !value.blank?
    end
    nil
  end
  
  def form_type
    return config[:form_type] if config[:form_type]
    config_options ? :select : :string
  end

  def extra_values=(ev)
    self.extra_value = YAML.dump(ev) if ev.is_a?(Hash)
    return ev
  end

  def extra_values
    ev_string = self.extra_value
    ev = ev_string.kind_of?(String) ? YAML.load(ev_string) : {}.with_indifferent_access
    ev = {}.with_indifferent_access unless ev.kind_of?(Hash)
    ev = ev.with_indifferent_access unless ev.kind_of?(ActiveSupport::HashWithIndifferentAccess)
    if block_given?
      yield ev
      self.extra_values = ev
    end
    return ev
  end

  def self.setting_extra_values(name)
    self.config(name).try(:extra_values) || {}.with_indifferent_access
  end

  def self.setting_extra_value(name, extra_name)
    self.setting_extra_values(name)[extra_name]
  end

end