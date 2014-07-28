class GpArticle::Admin::Tool::DocsController < Cms::Controller::Admin::Base
  def rebuild
    content = GpArticle::Content::Doc.find(params[:content_id])
    docs = content.public_docs.order('display_published_at DESC, published_at DESC')

    results = {ok: 0, ng: 0}
    errors = []

    docs.each do |doc|
      begin
        if doc.rebuild(render_public_as_string("#{doc.public_uri}index.html", site: content.site))
          doc.publish_page(render_public_as_string("#{doc.public_uri}index.html.r", site: content.site),
                           :path => "#{doc.public_path}.r", :dependent => :ruby)
          doc.rebuild(render_public_as_string("#{doc.public_uri}index.html", site: content.site, jpmobile: envs_to_request_as_smart_phone),
                      :path => doc.public_smart_phone_path, :dependent => :smart_phone)

          results[:ok] += 1
        end
      rescue => e
        results[:ng] += 1
        errors << "エラー： #{doc.id}, #{doc.title}, #{e.message}"
        error_log("Rebuild: #{e.message}")
      end
    end

    begin
      content.public_nodes.each do |node|
        target_controller = case node.model
                            when 'GpArticle::Doc'
                              '/gp_article/script/docs'
                            when 'GpArticle::Archive'
                              '/gp_article/script/archives'
                            else
                              nil
                            end
        next unless target_controller
        render_component_into_view :controller => target_controller, :action => 'publish',
                                   :params => {node_id: node.id}
      end
      results[:ok] += 1
    rescue => e
      results[:ng] += 1
      errors << "エラー： #{content.id}, #{content.name}, #{e.message}"
      error_log("Rebuild: #{e.message}")
    end

    messages = ["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"]
    messages.concat(errors)

    render text: messages.join('<br />')
  end
end
