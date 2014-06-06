class Organization::Admin::Tool::GroupsController < Cms::Controller::Admin::Base
  def pre_dispatch
    user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D201 Safari/9537.53'
    jpmobile = Jpmobile::Mobile::AbstractMobile.carrier('HTTP_USER_AGENT' => user_agent)
    @jpmobile = {'HTTP_USER_AGENT' => user_agent, 'rack.jpmobile' => jpmobile}
  end

  def rebuild
    content = Organization::Content::Group.find(params[:content_id])

    results = {ok: 0, ng: 0}
    errors = []

    content.groups.each do |group|
      begin
        if group.rebuild(render_public_as_string("#{group.public_uri}index.html", site: content.site))
          rendered = render_public_as_string("#{group.public_uri}index.html", site: content.site, jpmobile: @jpmobile)
          group.publish_page(rendered, path: group.public_smart_phone_path)

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
