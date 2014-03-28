# encoding: utf-8
class Survey::Admin::FormAnswersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Survey::Content::Form.find_by_id(params[:content])
    return error_auth unless @form = @content.forms.find_by_id(params[:form_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    @item = @form.form_answers.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @form.form_answers.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    _show @item
  end

  def destroy
    if @item.form.deletable? && @item.destroy
      redirect_to url_for(:action => :index), notice: "削除処理が完了しました。（#{I18n.l Time.now}）"
    else
      redirect_to url_for(:action => :show), alert: '削除処理に失敗しました。'
    end
  end
end
