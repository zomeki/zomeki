# encoding: utf-8
module Article::Controller::CacheSweeper
  # must include Sys::Controller::CacheSweeper::Base
  def sweepers
    [
      Article::Controller::Cache::NodeDoc,
      Article::Controller::Cache::NodeRecentDoc,
      Article::Controller::Cache::NodeAttribute,
      Article::Controller::Cache::NodeCategory,
      Article::Controller::Cache::NodeUnit,
      Article::Controller::Cache::NodeArea,
      Article::Controller::Cache::NodeEventDoc
    ]
  end

protected
  def save_rev_info(item)
    @rev_info = {}
    @org = Article::Doc.find_by_id(item)
    @rev_info[:item]          = @org
    @rev_info[:category_ids]  = @org.category_ids
    @rev_info[:attribute_id]  = @org.attribute_ids
    @rev_info[:area_ids]      = @org.area_ids
    @rev_info[:unit_id]       = @org.creator.group_id if @org.creator
  end

  def must_sweep?(mode, item)
    _must = false
    _must = true if (mode == :create && item.public?) ||
      mode == :update && (@org.public? || item.public?) ||
      mode == :destory && @org.public?
    _must
  end

end