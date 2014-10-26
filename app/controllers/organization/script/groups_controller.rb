class Organization::Script::GroupsController < Cms::Controller::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)

    @node.content.groups.each do |group|
      g_uri = group.public_uri
      g_path = group.public_path
      g_smart_phone_path = group.public_smart_phone_path
      publish_more(@node, uri: g_uri, path: g_path, smart_phone_path: g_smart_phone_path, dependent: g_uri)
    end

    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
