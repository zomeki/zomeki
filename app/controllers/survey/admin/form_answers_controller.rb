# encoding: utf-8
class Survey::Admin::FormAnswersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Survey::Content::Form.find_by_id(params[:content])
    return error_auth unless @form = @content.forms.find_by_id(params[:form_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @form.form_answers.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @form.form_answers.find(params[:id])
    _show @item
  end
end
