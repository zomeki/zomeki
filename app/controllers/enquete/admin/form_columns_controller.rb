# encoding: utf-8
class Enquete::Admin::FormColumnsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  helper Article::FormHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless @form = Enquete::Form.find(params[:form])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = Enquete::FormColumn.new#.public#.readable
    #item.public unless Core.user.has_auth?(:manager)
    item.and :form_id, @form.id
    #item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'sort_no ASC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Enquete::FormColumn.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    sql = "SELECT MAX(sort_no) AS max_sort_no FROM #{Enquete::FormColumn.table_name}" +
      " WHERE form_id = #{@form.id}" 
    rs = Enquete::FormColumn.connection.execute(sql)
    sort_no = (rs.fetch_hash['max_sort_no'] || 0).to_i + 1
    
    @item = Enquete::FormColumn.new({
      :state        => 'public',
      :required     => "1",
      :sort_no      => sort_no
    })
  end

  def create
    @item = Enquete::FormColumn.new(params[:item])
    @item.form_id = @form.id

    _create @item
  end

  def update
    @item = Enquete::FormColumn.new.find(params[:id])
    @item.attributes = params[:item]

    _update(@item)
  end

  def destroy
    @item = Enquete::FormColumn.new.find(params[:id])
    _destroy @item
  end

protected
end
