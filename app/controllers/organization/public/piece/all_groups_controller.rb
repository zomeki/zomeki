class Organization::Public::Piece::AllGroupsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Organization::Piece::AllGroup.where(id: Page.current_piece.id).first
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    sys_group_codes = @piece.content.root_sys_group.children.pluck(:code)
    @groups = @piece.content.groups.public.where(sys_group_code: sys_group_codes)
  end
end
