class Organization::Admin::Tool::GroupsController < Cms::Controller::Admin::Base
  def rebuild
    content = Organization::Content::Group.find(params[:content_id])

    results = {ok: 0, ng: 0}
    errors = []

    content.groups.each do |group|
      begin
        if group.rebuild(render_public_as_string("#{group.public_uri}index.html", site: content.site))
          results[:ok] += 1
        end
      rescue => e
        results[:ng] += 1
        errors << "エラー： #{group.id}, #{group.name}, #{e.message}"
        error_log("Rebuild: #{e.message}")
      end
    end

    messages = ["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"]
    messages.concat(errors)

    render text: messages.join('<br />')
  end
end
