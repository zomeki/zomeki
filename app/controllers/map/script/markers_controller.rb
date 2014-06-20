class Map::Script::MarkersController < Cms::Controller::Script::Publication
  def publish
    publish_more(@node, uri: @node.public_uri, limit: 3, path: @node.public_path,
                 dependent: 'more')
    publish_more(@node, uri: @node.public_uri, limit: 3, path: @node.public_smart_phone_path,
                 dependent: 'more_smart_phone', smart_phone: true)

    @node.content.public_markers.each do |marker|
      file = marker.files.first
      next unless file && ::File.exist?(file.upload_path)

      Util::File.put marker.public_file_path, src: file.upload_path, mkdir: true
      Util::File.put marker.public_smart_phone_file_path, src: file.upload_path, mkdir: true
    end

    render text: 'OK'
  end
end
