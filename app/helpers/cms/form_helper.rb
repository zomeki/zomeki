# encoding: utf-8
module Cms::FormHelper
  def node_navi
    render :partial => 'cms/admin/_partial/nodes/navi'
  end

  def concept_and_layout_form(form, options = {})
    #return form.hidden_field(:concept_id) unless Core.user.has_auth?(:manager)
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item, :layout => true}.merge(options)
    render :partial => 'cms/admin/_partial/concepts/form', :locals => locals
  end

  def concept_form(form, options = {})
    #return form.hidden_field(:concept_id) unless Core.user.has_auth?(:manager)
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'cms/admin/_partial/concepts/form', :locals => locals
  end

  def concept_view(item, options = {})
    locals = {:item => item}.merge(options)
    render :partial => 'cms/admin/_partial/concepts/view', :locals => locals
  end

  def layout_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'cms/admin/_partial/layouts/form', :locals => locals
  end

  def layout_view(item, options = {})
    locals = {:item => item}.merge(options)
    render :partial => 'cms/admin/_partial/layouts/view', :locals => locals
  end

  def content_base_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'cms/admin/_partial/contents/form', :locals => locals
  end

  def content_base_view(item, options = {})
    locals = {:item => item}.merge(options)
    render :partial => 'cms/admin/_partial/contents/view', :locals => locals
  end

  def node_base_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'cms/admin/_partial/nodes/form', :locals => locals
  end

  def node_base_view(item, options = {})
    locals = {:item => item}.merge(options)
    render :partial => 'cms/admin/_partial/nodes/view', :locals => locals
  end

  def piece_base_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'cms/admin/_partial/pieces/form', :locals => locals
  end

  def piece_base_view(item, options = {})
    locals = {:item => item}.merge(options)
    render :partial => 'cms/admin/_partial/pieces/view', :locals => locals
  end

  def inquiry_form(form)
    item = form.object
    item ||= instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}
    render :partial => 'cms/admin/_partial/inquiries/form', :locals => locals
  end

  def inquiry_view(item)
    locals = {:item => item}
    render :partial => 'cms/admin/_partial/inquiries/view', :locals => locals
  end

  def google_map_form(form)
    item = form.object
    item ||= instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}
    render :partial => 'cms/admin/_partial/maps/form', :locals => locals
  end

  def google_map_view(item)
    locals = {:item => item}
    render :partial => 'cms/admin/_partial/maps/view', :locals => locals
  end
end
