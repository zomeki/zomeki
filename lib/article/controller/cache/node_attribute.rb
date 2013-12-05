# encoding: utf-8
module Article::Controller::Cache::NodeAttribute
#   /_public/article/node_attributes/:name/:attr/index.:format    article/public/node/attributes#show_attr
#   /_public/article/node_attributes/:name/:file.:format          article/public/node/attributes#show
#   /_public/article/node_attributes/index.html(.:format)         article/public/node/attributes#index

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
    _item            = item
    _attribute_items = []
    _unit_items      = []
    if _mode == :update && _rev_info = options[:rev_info]
      # update
      if _rev_info[:item].public? && !item.public?
        _item             = _rev_info[:item]
        _attribute_items  = attribute_items _rev_info[:attribute_id]
        _unit_items      =  unit_items _rev_info[:unit_id]
      elsif !_rev_info[:item].public? &&  item.public?
        _attribute_items  = attribute_items item.attribute_ids
        _unit_items      =  unit_items item.unit
      elsif _rev_info[:item].public? &&  item.public?
        _attribute_items = attribute_items item.attribute_ids, _rev_info[:attribute_id]
        _unit_items      =  unit_items item.unit, _rev_info[:unit_id]
      end
    else
      # create || destroy
      _attribute_items = attribute_items item.attribute_ids
      _unit_items      =  unit_items item.unit
    end

    c = _item.content
    return false unless c

    _attribute_node = c.attribute_node
    return false unless _attribute_node

    # sweep ---------------
    _content_id = _attribute_node.content_id
    _concept_id = _attribute_node.concept_id

    # index
    _index_key = { :controller => 'article/public/node/attributes', :action => 'index', :format => 'html',
      :content => _content_id, :concept => _concept_id, :only_path => true }
    _reserve ? controller.reserve_expire_action(self, _index_key) : controller.do_expire_action(_index_key);

    # show_attr
    _attribute_items.each do |_a|
      ['html', 'rss', 'atom'].each do |_fmt|
        ['index', 'more'].each do |_f|
          # show
          _show_key = {:controller => 'article/public/node/attributes', :action => 'show', :file => _f, :format => _fmt,
              :name => _a.name, :content => _content_id, :concept => _concept_id, :only_path => true }
          _reserve ? controller.reserve_expire_action(self, _show_key) : controller.do_expire_action(_show_key);
        end

        # show_attr
        _unit_items.each do |_u|
          _show_attr_key = {:controller => 'article/public/node/attributes', :action => 'show_attr', :format => _fmt,
            :name => _a.name, :attr => _u.name_en, :content => _content_id, :concept => _concept_id, :only_path => true }
          _reserve ? controller.reserve_expire_action(self, _show_attr_key) : controller.do_expire_action(_show_attr_key);
        end

      end
    end

  end

  def self.attribute_items(ids1, ids2='')
    ids = ids1.to_s.split(' ') | ids2.to_s.split(' ')
    return [] if ids.size == 0

    item = Article::Attribute.new
    item.and :id, 'IN', ids
    item.find(:all)
  end

  def self.unit_items(obj1, obj2=nil)
    _ids    = []
    _items  = []
    [obj1, obj2].each do |o|
      _u = nil
      if Article::Unit === o
        _u = o
        _ids << _u.id
      elsif (String === o || Fixnum === o) && !o.to_s.blank?
        _u = Article::Unit.find_by_id(o)
        _ids << o
      end

      if _u
        if _u.level_no == 2
          _items << _u
        elsif _u.level_no == 3
          if _p = _u.parent
            _items << _p
          end
        end
      end
    end
    _items
  end

  module_function :sweep_exec?
  module_function :sweep_cache
end
