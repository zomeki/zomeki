module PortalGroup::Model::Rel::Doc::Area
  attr_accessor :in_portal_area_ids
  
  def in_portal_area_ids
    unless val = read_attribute(:in_portal_area_ids)
      write_attribute(:in_portal_area_ids, portal_area_ids.to_s.split(' ').uniq)
    end
    read_attribute(:in_portal_area_ids)
  end
  
  def in_portal_area_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each {|val| _ids << val}
      write_attribute(:portal_area_ids, _ids.join(' '))
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess
      ids.each {|key, val| _ids << val}
      write_attribute(:portal_area_ids, _ids.join(' '))
    else
      write_attribute(:portal_area_ids, ids)
    end
  end
  
  def portal_area_items
    ids = portal_area_ids.to_s.split(' ').uniq
    return [] if ids.size == 0
    item = PortalGroup::Area.new
    item.and :id, 'IN', ids
    item.find(:all)
  end
  
  def portal_area_is(cate)
    return self if cate.blank?
    cate = [cate] unless cate.class == Array
    ids  = []
    
    searcher = lambda do |_cate|
      _cate.each do |_c|
        next if _c.level_no > 5
        next if ids.index(_c.id)
        ids << _c.id
        searcher.call(_c.public_children)
      end
    end
    
    searcher.call(cate)
    ids = ids.uniq
    
    if ids.size > 0
      self.and :portal_area_ids, 'REGEXP', "(^| )(#{ids.join('|')})( |$)"
    end
    return self
  end
end