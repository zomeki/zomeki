class Gnav::Script::MenuItemsController < Cms::Controller::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)

    @node.content.menu_items.each do |menu_item|
      mi_uri = menu_item.public_uri
      mi_path = menu_item.public_path
      mi_smart_phone_path = menu_item.public_smart_phone_path
      publish_more(@node, uri: mi_uri, path: mi_path, smart_phone_path: mi_smart_phone_path, dependent: mi_uri)
    end

    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
