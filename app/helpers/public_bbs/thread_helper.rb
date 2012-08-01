# encoding: utf-8
module PublicBbs::ThreadHelper
  def public_bbs_thread_first_image(thread)
    if (img_src = thread.body.scan(/<img .*?(?<= )src="(.*?)".*?>/i).first)
      "#{thread.content.thread_node.public_uri}#{thread.id}/#{img_src.first}"
    end
  end
end
