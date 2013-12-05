# encoding: utf-8
module Article::Controller::Cache::NodeUnit
  #   /_public/article/node_units/:name/:attr/index.:format    article/public/node/units#show_attr
  #   /_public/article/node_units/:name/:file.:format          article/public/node/units#show
  #   /_public/article/node_units/index.html(.:format)         article/public/node/units#index

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

    _unit_node = c.unit_node
    return false unless _unit_node

    # sweep ---------------
    _content_id = _unit_node.content_id
    _concept_id = _unit_node.concept_id

    # index
    _index_key = {:controller => 'article/public/node/units', :action => 'index', :format => 'html',
      :content => _content_id, :concept => _concept_id, :only_path => true }
    _reserve ? controller.reserve_expire_action(self, _index_key) : controller.do_expire_action(_index_key);

    _unit_items.each do |_u|
      ['html', 'rss', 'atom'].each do |_fmt|
        ['index', 'more'].each do |_f|
          # show
          _show_key = {:controller => 'article/public/node/units', :action => 'show', :file => _f, :format => _fmt,
            :name => _u.name_en, :content => _content_id, :concept => _concept_id, :only_path => true }
          _reserve ? controller.reserve_expire_action(self, _show_key) : controller.do_expire_action(_show_key);

          # show_attr
          _attribute_items.each do |_a|
            _show_attr_key = {:controller => 'article/public/node/units', :action => 'show_attr', :format => _fmt,
              :name => _u.name_en, :attr => _a.name, :content => _content_id, :concept => _concept_id, :only_path => true }
            _reserve ? controller.reserve_expire_action(self, _show_attr_key) : controller.do_expire_action(_show_attr_key);
          end

          if _u.level_no == 3 && _p = _u.parent
            _show_parent_key = {:controller => 'article/public/node/units', :action => 'show', :file => _f, :format => _fmt,
              :name => _p.name_en, :content => _content_id, :concept => _concept_id, :only_path => true }
            _reserve ? controller.reserve_expire_action(self, _show_parent_key) : controller.do_expire_action(_show_parent_key);

            # show_attr
            _attribute_items.each do |_a|
              _show_attr_parent_key = {:controller => 'article/public/node/units', :action => 'show_attr', :format => _fmt,
                :name => _p.name_en, :attr => _a.name, :content => _content_id, :concept => _concept_id, :only_path => true }
              _reserve ? controller.reserve_expire_action(self, _show_attr_parent_key) : controller.do_expire_action(_show_attr_parent_key);
            end
          end
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
    _ids = []
    _items  = []
    [obj1, obj2].each do |o|
      _u = nil
      if Article::Unit === o
        _u = o
        _ids << o.id
      elsif (String === o || Fixnum === o) && !o.to_s.blank?
        _u = Article::Unit.find_by_id(o)
        _ids << o
      end
      _items << _u if _u
    end
    _items
  end

  module_function :sweep_exec?
  module_function :sweep_cache
end
