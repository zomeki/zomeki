# encoding: utf-8
module Sys::Controller::Scaffold::Base
  def edit
    show
  end
  
protected
  def _index(items)
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => items.to_xml(:dasherize => false, :root => 'items') }
    end
  end
  
  def _show(item)
    return send(params[:do], item) if params[:do]
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => item.to_xml(:dasherize => false, :root => 'item') }
    end
  end
  
  def _create(item, options = {}, &block)
    if item.creatable? && item.save
      item.reload if item.respond_to?(:reload) rescue nil
      status         = params[:_created_status] || :created
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(:action => :index)
      flash[:notice] = options[:notice] || "登録処理が完了しました。（#{I18n.l Time.now}）"
      Sys::OperationLog.log(request, :item => item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { render(:xml => item.to_xml(:dasherize => false), :status => status, :location => location) }
      end
    else
      failed_template = options[:failed_template] || {:action => :new}
      flash.now[:alert] = '登録処理に失敗しました。'
      respond_to do |format|
        format.html { render failed_template }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def _update(item, options = {}, &block)
    if item.editable? && item.save
      item.reload if item.respond_to?(:reload) rescue nil
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(:action => :index)
      Sys::OperationLog.log(request, :item => item)
      flash[:notice] = "更新処理が完了しました。（#{I18n.l Time.now}）"
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      failed_template = options[:failed_template] || {:action => :edit}
      flash.now[:alert] = '更新処理に失敗しました。'
      respond_to do |format|
        format.html { render failed_template }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def _destroy(item, options = {}, &block)
    if item.deletable? && item.destroy
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(:action => :index)
      flash[:notice] = options[:notice] || "削除処理が完了しました。（#{I18n.l Time.now}）"
      Sys::OperationLog.log(request, :item => item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash.now[:alert] = '削除処理に失敗しました。'
      respond_to do |format|
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
