# encoding: utf-8
module PublicBbs::FormHelper
  def public_bbs_categories_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'public_bbs/admin/_partial/categories/form', :locals => locals
  end

  def public_bbs_tags_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'public_bbs/admin/_partial/tags/form', :locals => locals
  end

  def public_bbs_thread_files_form(form, inline_id, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :inline_id => inline_id, :item => item}.merge(options)
    render :partial => 'public_bbs/admin/_partial/thread_files/form', :locals => locals
  end

  def public_bbs_response_files_form(form, inline_id, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :inline_id => inline_id, :item => item}.merge(options)
    render :partial => 'public_bbs/admin/_partial/response_files/form', :locals => locals
  end
end
