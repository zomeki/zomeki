# encoding: utf-8
module PortalArticle::FormHelper
  def portal_article_category_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'portal_article/admin/_partial/categories/form', :locals => locals
  end
  
  def portal_article_rel_doc_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'portal_article/admin/_partial/rel_docs/form', :locals => locals
  end
  
  def portal_article_tag_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'portal_article/admin/_partial/tags/form', :locals => locals
  end
end
