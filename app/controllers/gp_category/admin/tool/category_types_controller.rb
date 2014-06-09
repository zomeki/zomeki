class GpCategory::Admin::Tool::CategoryTypesController < Cms::Controller::Admin::Base
  def rebuild
    content = GpCategory::Content::CategoryType.find(params[:content_id])

    results = {ok: 0, ng: 0}
    errors = []

    if content.public_node
      content.category_types.each do |category_type|
        begin
          render_component_into_view :controller => '/gp_category/script/category_types', :action => 'publish',
                                     :params => {target_id: [category_type.id], node_id: content.public_node.id}
          results[:ok] += 1
        rescue => e
          results[:ng] += 1
          errors << "エラー： #{category_type.id}, #{category_type.title}, #{e.message}"
          error_log("Rebuild: #{e.message}")
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
