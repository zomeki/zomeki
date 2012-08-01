# encoding: utf-8
class PortalGroup::Admin::GroupsController < Cms::Controller::Admin::Base
  
  def index
    redirect_to portal_group_categories_path(params[:content], 0)
  end
  
  def categories
    roots = PortalGroup::Category.root_items(:content_id => params[:item_portal_group_id])
    @options = make_candidates(roots, :label => :title)
    @options = [["// 一覧を更新しました（#{@options.size}件）",'']] + @options
    
    render :action => :options, :layout => false
  end

  def businesses
    roots = PortalGroup::Business.root_items(:content_id => params[:item_portal_group_id])
    @options = make_candidates(roots, :label => :title)
    @options = [["// 一覧を更新しました（#{@options.size}件）",'']] + @options
    
    render :action => :options, :layout => false
  end

  def attributes
    cond  = {:content_id => params[:item_portal_group_id]}
    items = PortalGroup::Attribute.find(:all, :conditions => cond, :order => "content_id, sort_no")
    @options = items.collect{|c| [c.title, c.id]}
    @options = [["// 一覧を更新しました（#{@options.size}件）",'']] + @options
    
    render :action => :options, :layout => false
  end
  
  def areas
    roots = PortalGroup::Area.root_items(:content_id => params[:item_portal_group_id])
    @options = make_candidates(roots, :label => :title)
    @options = [["// 一覧を更新しました（#{@options.size}件）",'']] + @options
    
    render :action => :options, :layout => false
  end

protected
  def make_candidates(roots, options = {})
    value   = options[:value] || :id
    label   = options[:label] || :name
    order   = options[:order] || :sort_no
    cond    = options[:conditions] || {}
    
    choices = []
    roots = roots.to_a
    if roots.size > 0
      iclass  = roots[0].class
      indstr  = '　　'
      down = lambda do |_parent, _indent|
        choices << [(indstr * _indent) + _parent.send(label), _parent.send(value).to_s]
        iclass.find(:all, :conditions => cond.merge({:parent_id => _parent.id}), :order => order).each do |_child|
          down.call(_child, _indent + 1)
        end
      end
      roots.to_a.each {|item| down.call(item, 0)}
    end
    return choices
  end
end
