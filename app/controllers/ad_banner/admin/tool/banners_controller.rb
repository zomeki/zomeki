class AdBanner::Admin::Tool::BannersController < Cms::Controller::Admin::Base
  def rebuild
    content = AdBanner::Content::Banner.find(params[:content_id])

    results = {ok: 0, ng: 0}
    errors = []

    content.banners.each do |banner|
      begin
        banner.publish_or_close_image
        results[:ok] += 1
      rescue => e
        results[:ng] += 1
        errors << "エラー： #{banner.id}, #{banner.title}, #{e.message}"
        error_log("Rebuild: #{e.message}")
      end
    end

    messages = ["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"]
    messages.concat(errors)

    render text: messages.join('<br />')
  end
end
