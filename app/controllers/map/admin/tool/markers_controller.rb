class Map::Admin::Tool::MarkersController < Cms::Controller::Admin::Base
  def rebuild
    content = Map::Content::Marker.find(params[:content_id])

    results = {ok: 0, ng: 0}
    errors = []

    if (node = content.public_node)
      begin
        node.publish_page(render_public_as_string(node.public_uri, site: node.site))

        public_file_path = "#{node.public_path}index.html"
        public_smart_phone_file_path = "#{node.public_smart_phone_path}index.html"

        if ::File.exist?(public_file_path)
          rendered = render_public_as_string(node.public_uri, site: node.site, jpmobile: envs_to_request_as_smart_phone)
          Util::File.put(public_smart_phone_file_path, :data => rendered, :mkdir => true)
        else
          FileUtils.rm public_smart_phone_file_path if ::File.exist?(public_smart_phone_file_path)
          FileUtils.rmdir node.public_smart_phone_path
        end

        content.public_markers.each do |marker|
          file = marker.files.first
          next unless file && ::File.exist?(file.upload_path)

          Util::File.put marker.public_file_path, src: file.upload_path, mkdir: true
          Util::File.put marker.public_smart_phone_file_path, src: file.upload_path, mkdir: true
        end

        results[:ok] += 1
      rescue => e
        results[:ng] += 1
        errors << "エラー： #{node.id}, #{node.title}, #{e.message}"
        error_log("Rebuild: #{e.message}")
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
