# encoding: utf-8
module Article::Controller::Cache::NodeDoc
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
    # mode = :create or :update or :destroy
    true
  end

  def sweep_cache(controller, item, options={} )
    _reserve = options[:reserve] || false

    #Article::Content::Doc
    if c = item.content
      # show
      #_show_key = {:controller => 'article/public/node/docs', :action => 'show',
      #  :content => item.content_id, :concept => c.concept_id, :name => item.name, :only_path => true}
      #_reserve ? controller.reserve_expire_action(self, _show_key) : controller.do_expire_action(_show_key);
      if _docs_node = c.doc_node
        # index
        _index_key = {:controller => 'article/public/node/docs', :action => 'index', :format => 'html',
          :content => _docs_node.content_id, :concept => _docs_node.concept_id, :only_path => true }
        _reserve ? controller.reserve_expire_action(self, _index_key) : controller.do_expire_action(_index_key);
      end
    end
  end

  module_function :sweep_exec?
  module_function :sweep_cache
end
