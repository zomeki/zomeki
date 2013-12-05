# encoding: utf-8
module Article::Controller::Cache::NodeRecentDoc
  # /_public/article/node_recent_docs/index.:format article/public/node/recent_docs#index

  def self.included(mod)
    mod.caches_action :index,
    :cache_path => Proc.new {|c|
      { :format => @format, :content => @content_id, :concept => @concept_id, :only_path => true }
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

    #Article::Content::Doc
    if c = item.content
      if _recent_node = c.recent_node
        ['html', 'rss', 'atom'].each do |_fmt|
          # index
          _index_key = {:controller => 'article/public/node/recent_docs', :action => 'index', :format => _fmt,
            :content => _recent_node.content_id, :concept => _recent_node.concept_id, :only_path => true }
          _reserve ? controller.reserve_expire_action(self, _index_key) : controller.do_expire_action(_index_key);
        end
      end
    end
  end

  module_function :sweep_exec?
  module_function :sweep_cache
end
