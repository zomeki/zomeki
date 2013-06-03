# encoding: utf-8
module Sys::Model::Rel::UnidRelation
  def self.included(mod)
    mod.has_many :rel_unids, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'Sys::UnidRelation',
      :dependent => :destroy
    mod.has_many :rel_unids_for_destroy, :primary_key => 'unid', :foreign_key => 'rel_unid', :class_name => 'Sys::UnidRelation',
      :dependent => :destroy
  end
  
  def unid_related?(options = {})
    cond = nil
    if options[:from]
      cond = {:unid => unid, :rel_type => options[:from].to_s}
    elsif options[:to]
      cond = {:rel_unid => unid, :rel_type => options[:to].to_s}
    else
      cond = ["unid = ? OR rel_unid = ?", unid, unid]
    end
    Sys::UnidRelation.find(:first, :conditions => cond) ? true : nil
  end
  
  def replace_page?
    cond = {:unid => unid, :rel_type => "replace"}
    Sys::UnidRelation.find(:first, :conditions => cond) ? true : nil
  end
  
  def replaced_page?
    cond = {:rel_unid => unid, :rel_type => "replace"}
    Sys::UnidRelation.find(:first, :conditions => cond) ? true : nil
  end
  
  def replace_page
    return nil unless replaced_page?
    cond = {:rel_unid => unid, :rel_type => "replace"}
    rel = Sys::UnidRelation.find(:first, :conditions => cond)
    self.class.find_by_unid(rel.unid)
  end
  
  def replaced_page
    return nil unless replace_page?
    cond = {:unid => unid, :rel_type => "replace"}
    rel = Sys::UnidRelation.find(:first, :conditions => cond)
    self.class.find_by_unid(rel.rel_unid)
  end
 end
