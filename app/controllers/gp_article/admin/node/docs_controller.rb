class GpArticle::Admin::Node::DocsController < Cms::Admin::Node::DirectoriesController
  after_filter :publish_node, only: [:update]

  private

  def publish_node
    ::Script.delay(queue: "publish_node_#{@item.id}")
            .run("cms/script/nodes/publish?target_module=cms&target_node_id=#{@item.id}", force: true)
  end
end
