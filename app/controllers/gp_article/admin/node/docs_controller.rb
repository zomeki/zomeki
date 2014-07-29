class GpArticle::Admin::Node::DocsController < Cms::Admin::Node::BaseController
  def model
    Cms::Node::Directory
  end
end
