class GpArticle::Admin::Tool::DocsController < Cms::Controller::Admin::Base
  def rebuild
    docs = GpArticle::Content::Doc.find(params[:content_id]).public_docs
                                  .order('display_published_at DESC, published_at DESC')

    results = {ok: 0, ng: 0}
    errors = []

    docs.each do |doc|
      begin
        if doc.rebuild(render_public_as_string("#{doc.public_uri}index.html", site: doc.content.site))
          doc.publish_page(render_public_as_string("#{doc.public_uri}index.html.r", site: doc.content.site),
                           :path => "#{doc.public_path}.r", :dependent => :ruby)
          results[:ok] += 1
        end
      rescue => e
        results[:ng] += 1
        errors << "エラー： #{doc.id}, #{doc.title}, #{e.message}"
        error_log("Rebuild: #{e.message}")
      end
    end

    messages = ["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"]
    messages.concat(errors)

    render text: messages.join('<br />')
  end
end
