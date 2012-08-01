# encoding: utf-8
module PortalGroup::FormHelper
  def portal_group_category_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'portal_group/admin/_partial/categories/form', :locals => locals
  end
  
  def portal_group_business_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'portal_group/admin/_partial/businesses/form', :locals => locals
  end
  
  def portal_group_attribute_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'portal_group/admin/_partial/attributes/form', :locals => locals
  end
  
  def portal_group_area_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'portal_group/admin/_partial/areas/form', :locals => locals
  end
end
