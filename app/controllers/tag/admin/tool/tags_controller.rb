class Tag::Admin::Tool::TagsController < Cms::Controller::Admin::Base
  def rebuild
    content = Tag::Content::Tag.find(params[:content_id])

    results = {ok: 0, ng: 0}
    errors = []

    if (nodes = content.public_nodes).count > 0
      nodes.each do |node|
        begin
          ctrl = node.model.underscore.pluralize.sub(/\A(.+?)\//, '/\1/script/')
          render_component_into_view controller: ctrl, action: 'publish',
                                     params: {node_id: node.id}
          results[:ok] += 1
        rescue => e
          results[:ng] += 1
          error_log("Failed to rebuild: #{e.message}")
        end
      end
    else
      results[:ng] += 1
      errors << 'エラー： ディレクトリが作成されていません。'
    end

    messages = ["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"]
    messages.concat(errors)

    render text: messages.join('<br />')
  end
end
