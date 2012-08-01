# encoding: utf-8
class PublicBbs::Public::Node::RecentThreadsController < Cms::Controller::Public::Base
  def pre_dispatch
    content = Page.current_node.content
    @content = PublicBbs::Content::Thread.find(content) if content.model == 'PublicBbs::Thread'
    return http_error(404) unless @content
  end

  def index
    sort = case params[:sort]
           when 't_d'; 'last_updated_at DESC, updated_at DESC'
           when 'n_d'; 'num_reses DESC, updated_at DESC'
           end

    thread = PublicBbs::Thread.new.public
    thread.and :content_id, @content.id
    thread.page  params[:page], 10
    thread.order sort, 'updated_at DESC'

    select_from_pbr = "(SELECT %s FROM public_bbs_responses AS pbr WHERE pbr.thread_id = public_bbs_threads.id AND pbr.state = 'public')"
    num_reses = select_from_pbr % 'COUNT(pbr.id)'
    last_reses_updated_at = select_from_pbr % 'MAX(pbr.updated_at)'
    thread_updated_at = 'public_bbs_threads.updated_at'
    @threads = thread.find(:all, :select => "public_bbs_threads.*, #{num_reses} AS num_reses, IF(#{last_reses_updated_at} > #{thread_updated_at}, #{last_reses_updated_at}, #{thread_updated_at}) AS last_updated_at")

    return http_error(404) if @threads.current_page > @threads.total_pages
  end
end
