class Organization::Public::Node::GroupsController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = Organization::Content::Group.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    sys_group_codes = @content.root_sys_group.children.pluck(:code)
    @groups = @content.groups.where(sys_group_code: sys_group_codes)
  end

  def show
#    @group = @content.find_group_by_path_from_root(params[:group_names])
    @group = @content.groups.where(name: params[:group_names]).first
    return http_error(404) unless @group.try(:public?)

    Page.current_item = @group
    Page.title = @group.sys_group.name

    @docs = find_public_docs_with_group_id(@group.sys_group.id).order(@group.docs_order)
                                 .paginate(page: params[:page], per_page: 10)
  end

  private

  def find_public_docs_with_group_id(group_id)
    GpArticle::Doc.all_with_content_and_criteria(nil, group_id: group_id).mobile(::Page.mobile?).public
  end
end
