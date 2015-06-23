# encoding: utf-8
class Survey::Public::Piece::FormsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Survey::Piece::Form.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    public_node = @piece.content.public_node
    return render(:text => '') unless public_node

    target_form = @piece.target_form
    return render(:text => '') unless target_form

    if Core.mode != 'preview' && Sys::Setting.use_common_ssl? && @piece.content.use_common_ssl?
      @target_form_public_uri = "#{Page.site.full_ssl_uri.sub(/\/\z/, '')}#{public_node.public_uri}#{target_form.name}"
    else
      @target_form_public_uri = if Core.mode == 'preview'
                                  "#{public_node.preview_uri}#{target_form.name}"
                                else
                                  "#{public_node.public_uri}#{target_form.name}"
                                end
    end
  end
end
