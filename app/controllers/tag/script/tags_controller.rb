class Tag::Script::TagsController < Cms::Controller::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s

    @node.content.tags.each do |tag|
      publish_more(@node, uri: tag.public_uri, path: tag.public_path,
                                   smart_phone_path: tag.public_smart_phone_path, dependent: tag.public_uri)
    end

    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
