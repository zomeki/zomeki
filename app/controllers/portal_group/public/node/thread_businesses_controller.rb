# encoding: utf-8
class PortalGroup::Public::Node::ThreadBusinessesController < Cms::Controller::Public::Base
  def pre_dispatch
    content = Page.current_node.content
    @content = PortalGroup::Content::Group.find(content) if content.model == 'PortalGroup::Group'
    return http_error(404) unless @content

    if params[:name]
      item = PortalGroup::Business.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end

  def index
    @items = PortalGroup::Business.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    business_ids = [@item.id].concat(@item.public_descendants)

    thread = PublicBbs::Thread.new.public
    thread.and :portal_group_id, @content.id
    thread.portal_business_is PortalGroup::Business.find(business_ids)
    thread.page params[:page], 50
    thread.order nil, 'created_at DESC'

    select_from_pbr = "(SELECT %s FROM public_bbs_responses AS pbr WHERE pbr.thread_id = public_bbs_threads.id AND pbr.state = 'public')"
    num_reses = select_from_pbr % 'COUNT(pbr.id)'
    last_reses_updated_at = select_from_pbr % 'MAX(pbr.updated_at)'
    thread_updated_at = 'public_bbs_threads.updated_at'
    @threads = thread.find(:all, :select => "public_bbs_threads.*, #{num_reses} AS num_reses, IF(#{last_reses_updated_at} > #{thread_updated_at}, #{last_reses_updated_at}, #{thread_updated_at}) AS last_updated_at").select{|t| t.content.thread_node }.paginate

    return http_error(404) if @threads.current_page > @threads.total_pages
  end
end
