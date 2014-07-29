class GpArticle::Admin::Node::ArchivesController < Cms::Admin::Node::BaseController
  def model
    Cms::Node::Directory
  end
end
