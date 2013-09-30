# encoding: utf-8
class Survey::Admin::QuestionsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Survey::Content::Form.find_by_id(params[:content])
    return error_auth unless @form = @content.forms.find_by_id(params[:form_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @form.questions.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @form.questions.find(params[:id])
    _show @item
  end

  def new
    @item = @form.questions.build
  end

  def create
    @item = @form.questions.build(params[:item])
    _create @item
  end

  def update
    @item = @form.questions.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @form.questions.find(params[:id])
    _destroy @item
  end
end
