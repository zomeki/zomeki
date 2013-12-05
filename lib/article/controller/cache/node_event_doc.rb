# encoding: utf-8
module Article::Controller::Cache::NodeEventDoc
#   /_public/article/node_event_docs/:year/:month/index.:format  article/public/node/event_docs#month
#   /_public/article/node_event_docs/index.:format               article/public/node/event_docs#month

  def self.included(mod)
    mod.caches_action :month,
    :cache_path => Proc.new {|c|
      { :format => @format, :content => @content_id, :concept => @concept_id, :year => @year, :month => @month, :only_path => true }
    },
    :if => Proc.new {|c|
      !c.request.mobile? && (params[:page] == '1' || params[:page] == nil) &&
      Core.mode == 'public'
    }
  end

  def set_cache_path_info
    @format = params[:format]
    @content_id = @content.id
    @concept_id = Page.current_node ? Page.current_node.concept_id : 0;
    now = Time.now
    @year  = params[:year] ? params[:year].to_i : now.year;
    @month = params[:month] ? params[:month].to_i : now.month;
  end

  def sweep_exec?(mode, item, options={} )
    exec = false
    rev = options[:rev_info] ? options[:rev_info][:item] : nil;
    [item, rev].each do |_item|
      exec = exec || _item.event_state == 'visible' if _item
    end
    exec
  end

  def sweep_cache(controller, item, options={} )
    _reserve = options[:reserve] || false
    _mode    = options[:mode] || :create

    _item = item
    _dates = []

    require "date"
    d = Date.today << 12
    12.times {|m| _dates << (d << m)}

    if _mode == :update && _rev_info = options[:rev_info]
      # update
      if _rev_info[:item].public? && !item.public?
        _item  = _rev_info[:item]
        _dates << _item.event_date if _item.event_date
      elsif !_rev_info[:item].public? &&  item.public?
        _dates << _item.event_date if _item.event_date
      elsif _rev_info[:item].public? &&  item.public?
        _dates << _rev_info[:item].event_date if _rev_info[:item].event_date
        _dates << _item.event_date if _item.event_date
      end
    else
      # create || destroy
      _dates << _item.event_date if _item.event_date
    end

    c = _item.content
    return false unless c

    _event_node = c.event_node
    return false unless _event_node

    # sweep ---------------
    _content_id = _event_node.content_id
    _concept_id = _event_node.concept_id

    _dates.each do |_d|
      ['html', 'rss', 'atom'].each do |_fmt|
        # index
        _index_key = {:controller => 'article/public/node/event_docs', :action => 'month', :format => _fmt,
          :content => _content_id, :concept => _concept_id, :year => _d.year, :month => _d.month, :only_path => true }
        _reserve ? controller.reserve_expire_action(self, _index_key) : controller.do_expire_action(_index_key);
      end
    end

  end

  module_function :sweep_exec?
  module_function :sweep_cache
end
