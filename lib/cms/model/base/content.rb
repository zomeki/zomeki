# encoding: utf-8
module Cms::Model::Base::Content
  def self.included(mod)
    mod.belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  end
  
  def states
    [['公開','public'],['非公開','closed']]
  end
  
  def model_name(option = nil)
    name = Cms::Lib::Modules.model_name(:content, model)
    return name.to_s.gsub(/.*\//, '') if option == :short
    name
  end
  
  def public_path
    id_dir  = Util::String::CheckDigit.check(format('%07d', id)).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    "#{site.public_path}/_contents/#{id_dir}"
  end
  
  def public_uri(class_name)
    cond = {:content_id => id, :model => class_name.to_s}
    return nil unless node = Cms::Node.find(:first, :conditions => cond, :order => :id)
    node.public_uri
  end
  
  def admin_uri
    controller = model.underscore.pluralize.gsub(/^(.*?\/)/, "\\1#{id}/")
    "#{Core.uri}#{ZomekiCMS::ADMIN_URL_PREFIX}/#{controller}"
  end
  
  def admin_content_uri
    controller = model.to_s.underscore.pluralize.gsub(/^(.*?)\/.*/, "\\1/content_base") + "/#{id}"
    "#{Core.uri}#{ZomekiCMS::ADMIN_URL_PREFIX}/#{controller}"
  end
end
