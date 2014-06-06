# encoding: utf-8
class Cms::Admin::Tool::RebuildController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    
    if params.key?(:test)
      start = Time.now.to_f
      rs = render_component_into_view(:controller => 'cms/script/nodes', :action => 'publish')
      flash.now[:notice] = "ページを書き出しました。"
    end

    user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D201 Safari/9537.53'
    jpmobile = Jpmobile::Mobile::AbstractMobile.carrier('HTTP_USER_AGENT' => user_agent)
    @jpmobile = {'HTTP_USER_AGENT' => user_agent, 'rack.jpmobile' => jpmobile}
  end
  
  def index
    @item = Cms::Node.new(params[:item])
    if params[:do] == 'content'
      Core.messages << "再構築： コンテンツ"
      
      item = Cms::Content.new
      item.and :model, 'LIKE', '%::Doc'
      item.and :model, '!=', 'GpArticle::Doc'
      item.and :model, '!=', 'Newsletter::Doc'
      item.and :model, '!=', 'Laby::Doc'
      item.and :site_id, Core.site.id
      item.and :id, @item.content_id if !@item.content_id.blank?
      items = item.find(:all)
      items.each do |item|
        ctl = item.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/admin/tool/')
        act = 'rebuild'
        prm = params.merge({:content => item})
        begin
          Core.messages << "#{item.name}"
          render_component_into_view :controller => ctl, :action => act, :params => prm
        rescue => e
          Core.messages << "-- Error #{e}"
        end
      end
      
    elsif params[:do] == 'styleseet'
      Core.messages << "再構築： スタイルシート"
      
      results = [0, 0]
      item = Cms::Layout.new
      item.and :site_id, Core.site.id
      item.and :concept_id, @item.concept_id if !@item.concept_id.blank?
      items = item.find(:all)
      items.each do |item|
        begin
          if item.put_css_files
            results[0] += 1
          end
        rescue => e
          results[1] += 1
        end
      end
      
      Core.messages << "-- 成功 #{results[0]}件"
      Core.messages << "-- 失敗 #{results[1]}件"
    end
    
    if !Core.messages.empty?
      max_messages = 3000
      messages = Core.messages.join('<br />')
      if messages.size > max_messages
        messages = ApplicationController.helpers.truncate(messages, :length => max_messages)
      end
      flash[:notice] = ('再構築が終了しました。<br />' + messages).html_safe
      redirect_to :action => :index
    end
  end

  def rebuild_contents
    contents = Cms::Content.where(id: params[:target_content_ids])
    return redirect_to(url_for(action: 'index'), alert: '対象を選択してください。') if contents.empty?

    result_message = ['再構築：コンテンツ']

    contents.each do |content|
      ctl = content.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/admin/tool/')
      act = 'rebuild'
      prm = params.merge(content_id: content.id)
      begin
        result_message << content.name
        result_message << render_component_into_view(:controller => ctl, :action => act, :params => prm)
      rescue => e
        result_message << "-- 失敗 #{e.message}"
      end
    end

    notice_message = '再構築が終了しました。'

    unless result_message.empty?
      max_messages = 3000
      messages = result_message.join('<br />')
      if messages.size > max_messages
        messages = ApplicationController.helpers.truncate(messages, :length => max_messages)
      end
      notice_message << "<br />#{messages}"
    end

    redirect_to url_for(action: 'index'), notice: notice_message.html_safe
  end

  def rebuild_nodes
    nodes = Cms::Node.where(id: params[:target_node_ids])
    return redirect_to(url_for(action: 'index'), alert: '対象を選択してください。') if nodes.empty?

    result_message = ['再構築：ページ']

    results = {ok: 0, ng: 0}
    errors = []

    nodes.each do |node|
      begin
        node.publish_page(render_public_as_string(node.public_uri, site: node.site))

        if ::File.exist?(node.public_path)
          rendered = render_public_as_string(node.public_uri, site: node.site, jpmobile: @jpmobile)
          FileUtils.mkdir_p ::File.dirname(node.public_smart_phone_path)
          ::File.open(node.public_smart_phone_path, 'w'){|f| f.write rendered }
        else
          FileUtils.rm node.public_smart_phone_path if ::File.exist?(node.public_smart_phone_path)
          FileUtils.rmdir ::File.dirname(node.public_smart_phone_path)
        end

        results[:ok] += 1
      rescue => e
        results[:ng] += 1
        errors << "エラー： #{node.id}, #{node.title}, #{e.message}"
        error_log("Rebuild: #{e.message}")
      end
    end

    result_message.concat(["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"])
    result_message.concat(errors)

    notice_message = '再構築が終了しました。'

    unless result_message.empty?
      max_messages = 3000
      messages = result_message.join('<br />')
      if messages.size > max_messages
        messages = ApplicationController.helpers.truncate(messages, :length => max_messages)
      end
      notice_message << "<br />#{messages}"
    end

    redirect_to url_for(action: 'index'), notice: notice_message.html_safe
  end
end
