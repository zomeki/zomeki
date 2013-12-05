# encoding: utf-8
module Article::Controller::Cache::NodeArea
#   /_public/article/node_areas/:name/:attr/index.:format    article/public/node/areas#show_attr
#   /_public/article/node_areas/:name/:file.:format          article/public/node/areas#show
#   /_public/article/node_areas/index.html(.:format)         article/public/node/areas#index

  def self.included(mod)
    mod.caches_action :index, :show, :show_attr,
    :cache_path => Proc.new {|c|
      { :format => @format, :content => @content_id, :concept => @concept_id, :only_path => true }
    },
    :if => Proc.new {|c|
      !c.request.mobile? && ([nil, 'index', 'more'].include?(params[:file])) &&
      (params[:page] == '1' || params[:page] == nil) &&
      Core.mode == 'public'
    }
  end

  def set_cache_path_info
    @format = params[:format]
    @content_id = @content.id
    @concept_id = Page.current_node ? Page.current_node.concept_id : 0;
  end

  def sweep_exec?(mode, item, options={} )
    exec = false
    rev = options[:rev_info] ? options[:rev_info][:item] : nil;
    [item, rev].each do |_item|
      exec = exec || _item.recent_state == 'visible' || _item.list_state == 'visible' if _item
    end
    exec
  end

  def sweep_cache(controller, item, options={} )
    _reserve = options[:reserve] || false
    _mode    = options[:mode] || :create

    # set target
    _item       = item
    _area_items = []
    _attribute_items = []
    if _mode == :update && _rev_info = options[:rev_info]
      # update
      if _rev_info[:item].public? && !item.public?
        _item             = _rev_info[:item]
        _area_items       = area_items _rev_info[:area_ids]
        _attribute_items  = attribute_items _rev_info[:attribute_id]
      elsif !_rev_info[:item].public? &&  item.public?
        _area_items       = area_items item.area_ids
        _attribute_items  = attribute_items item.attribute_ids
      elsif _rev_info[:item].public? &&  item.public?
        _area_items      = area_items item.area_ids, _rev_info[:area_ids]
        _attribute_items = attribute_items item.attribute_ids, _rev_info[:attribute_id]
      end
    else
      # create || destroy
      _area_items      = area_items item.area_ids
      _attribute_items = attribute_items item.attribute_ids
    end

    c = _item.content
    return false unless c

    _area_node = c.area_node
    return false unless _area_node

    # sweep ---------------
    _content_id = _area_node.content_id
    _concept_id = _area_node.concept_id

    # index
    _index_key = {:controller => 'article/public/node/areas', :action => 'index', :format => 'html',
      :content => _content_id, :concept => _concept_id, :only_path => true }
    _reserve ? controller.reserve_expire_action(self, _index_key) : controller.do_expire_action(_index_key);
    _area_items.each do |_a|
      ['html', 'rss', 'atom'].each do |_fmt|
        ['index', 'more'].each do |_f|
          # show
          _show_key = {:controller => 'article/public/node/areas', :action => 'show', :file => _f, :format => _fmt,
            :name => _a.name, :content => _content_id, :concept => _concept_id, :only_path => true }
           _reserve ? controller.reserve_expire_action(self, _show_key) : controller.do_expire_action(_show_key);
          # show_attr
          _attribute_items.each do |_attr|
            _show_attr_key = {:controller => 'article/public/node/areas', :action => 'show_attr', :file => _f, :format => _fmt,
              :name => _a.name, :attr => _attr.name, :content => _content_id, :concept => _concept_id, :only_path => true }
            _reserve ? controller.reserve_expire_action(self, _show_attr_key) : controller.do_expire_action(_show_attr_key);
          end
        end
      end
    end

  end

  def self.area_items(ids1, ids2='')
    ids = ids1.to_s.split(' ') | ids2.to_s.split(' ')
    return [] if ids.size == 0

    _items = []
    _parent_ids = []
    item = Article::Area.new
    item.and :id, 'IN', ids
    item.find(:all).each do |a|
      _parent_ids << a.parent_id if a.level_no == 2
      _items << a
    end
    parent = Article::Area.new
    parent.and :id, 'IN', _parent_ids
    _items += parent.find(:all).to_a
    _items
  end

  def self.attribute_items(ids1, ids2='')
    ids = ids1.to_s.split(' ') | ids2.to_s.split(' ')
    return [] if ids.size == 0

    item = Article::Attribute.new
    item.and :id, 'IN', ids
    item.find(:all)
  end

  module_function :sweep_exec?
  module_function :sweep_cache
end
