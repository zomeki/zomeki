# encoding: utf-8
module Sys::Controller::CacheSweeper::Base
  def sweepers
    # must override
    []
  end

  def reserve_sweeper
    @reserve_sweeper = true
    @reserve_sweeper
  end

  def reserve_sweeper?
    @reserve_sweeper
  end

  def item_updated
    @item_updated = true
    @item_updated
  end
  def item_updated?
    @item_updated
  end

  def swept
    @swept = true
    @swept
  end
  def swept?
    @swept
  end

  def reset_sweep_state
    @item_updated = nil
    @swept        = nil
  end

  def before_update_for_sweeper(item)
    return true if item_updated?
    save_rev_info item
  end

  def before_destory_for_sweeper(item)
    return true if item_updated?
    save_rev_info item
  end

  def sweep_cache_for_create(item)
    sweep_cache(:create, item)
  end

  def sweep_cache_for_update(item)
    sweep_cache(:update, item)
    item_updated
  end

  def sweep_cache_for_destory(item)
    sweep_cache(:destory, item)
    item_updated
  end

  def do_expire_action(options = {})
    expire_action options
  end

  def reserve_expire_action(sweeper, key, options={})
    _model = sweeper.name
    _key   = url_for key  # key == hash

    s = Sys::CacheSweeper.new
    s.and :model, _model
    s.and :uri, _key
    unless s.find(:first)
      Sys::CacheSweeper.new(
        :state => 'enabled',
        :model => _model,
        :uri => _key
      ).save(:validate => false)
    end
  end

protected
  def save_rev_info(item)
    # must override
    @rev_info = {}
  end

  def must_sweep?(mode, item)
    # must override
    true
  end

  def sweep_cache(mode, item)
    return true if swept?
    return true unless must_sweep?(mode, item)

    sweepers.each do |sw|
      if sw.sweep_exec?(mode, item, :rev_info => @rev_info)
        sw.sweep_cache(self, item, {:mode => mode, :reserve => reserve_sweeper?, :rev_info => @rev_info})
      end
    end
    swept
  end
end
