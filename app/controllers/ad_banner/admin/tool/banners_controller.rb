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
        message = e.message.force_encoding(Encoding::UTF_8).scrub
        errors << "エラー： #{banner.id}, #{banner.title}, #{message}"
        error_log("Rebuild: #{message}")
      end
    end

    messages = ["-- 成功 #{results[:ok]}件", "-- 失敗 #{results[:ng]}件"]
    messages.concat(errors)

    render text: messages.join('<br />')
  end
end
