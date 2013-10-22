# encoding: utf-8

require 'csv'

class Survey::Admin::FormsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Survey::Content::Form.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.forms.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @content.forms.find(params[:id])
    _show @item
  end

  def new
    @item = @content.forms.build
  end

  def create
    @item = @content.forms.build(params[:item])
    _create @item
  end

  def update
    @item = @content.forms.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @content.forms.find(params[:id])
    _destroy @item
  end

  def download_form_answers
    @item = @content.forms.find(params[:id])

    csv_string = CSV.generate do |csv|
      header = [Survey::FormAnswer.human_attribute_name(:created_at),
                "#{Survey::FormAnswer.human_attribute_name(:answered_url)}URL",
                "#{Survey::FormAnswer.human_attribute_name(:answered_url)}タイトル",
                Survey::FormAnswer.human_attribute_name(:remote_addr),
                Survey::FormAnswer.human_attribute_name(:user_agent)]

      @item.questions.each{|q| header << q.title }

      csv << header

      @item.form_answers.each do |form_answer|
        line = [I18n.l(form_answer.created_at),
                form_answer.answered_url,
                form_answer.answered_url_title,
                form_answer.remote_addr,
                form_answer.user_agent]

        @item.questions.each{|q| line << form_answer.answers.find_by_question_id(q.id).try(:content) }

        csv << line
      end
    end

    send_data csv_string.encode(Encoding::WINDOWS_31J, :invalid => :replace, :undef => :replace),
              type: Rack::Mime.mime_type('.csv'), filename: 'answers.csv'
  end
end
