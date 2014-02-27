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
    @group = @content.find_group_by_path_from_root(params[:group_names])
    return http_error(404) unless @group.try(:public?)

    Page.current_item = @group
    Page.title = @group.sys_group.name
  end
end
