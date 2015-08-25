class Map::Admin::Tool::MarkersController < Cms::Controller::Admin::Base
  def rebuild
    content = Map::Content::Marker.find(params[:content_id])

    results = {ok: 0, ng: 0}
    errors = []

    content.public_nodes.each do |node|
      begin
        render_component_into_view :controller => '/map/script/markers', :action => 'publish',
                                   :params => {node_id: node.id}
        results[:ok] += 1
      rescue => e
        results[:ng] += 1
        errors << "エラー： #{node.id}, #{node.title}, #{e.message}"
        error_log("Rebuild: #{e.message}")
      end
    end

    if content.public_nodes.empty?
      results[:ng] += 1
      errors << 'エラー： ディレクトリが作成されていません。'
    end

    messages = ["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"]
    messages.concat(errors)

    render text: messages.join('<br />')
  end
end
