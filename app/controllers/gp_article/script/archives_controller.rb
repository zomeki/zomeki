class GpArticle::Script::ArchivesController < Cms::Controller::Script::Publication
  def publish
    publish_page(@node, uri: @node.public_uri, site: @node.site,
                        path: @node.public_path, smart_phone_path: @node.public_smart_phone_path)
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
