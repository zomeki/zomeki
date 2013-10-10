# encoding: utf-8
class Survey::Public::Node::FormsController < Cms::Controller::Public::Base
  before_filter :set_form, only: [:show, :confirm_answers, :send_answers]

  def pre_dispatch
    @node = Page.current_node
    @content = Survey::Content::Form.find_by_id(@node.content.id)
    return http_error(404) unless @content
  end

  def index
    @forms = @content.public_forms
  end

  def show
    @form_answer = @form.form_answers.build
  end

  def confirm_answers
    @form_answer = @form.form_answers.build
    @form_answer.question_answers = params[:question_answers]
    render(action: 'show') unless @form_answer.valid?
  end

  def send_answers
    @form_answer = @form.form_answers.build
    @form_answer.question_answers = params[:question_answers]
    return render(action: 'show') if params[:edit_answers]
    return render(action: 'show') unless @form_answer.save
    redirect_to "#{@node.public_uri}#{@form_answer.form.name}/finish"
  end

  private

  def set_form
    @form = @content.public_forms.find_by_name(params[:id])
    return http_error(404) unless @form

    Page.current_item = @form
    Page.title = @form.title
  end
end
