module PortalGroup::Model::Rel::Site::Business
  attr_accessor :in_portal_business_ids
  
  def in_portal_business_ids
    unless val = read_attribute(:in_portal_business_ids)
      write_attribute(:in_portal_business_ids, portal_business_ids.to_s.split(' ').uniq)
    end
    read_attribute(:in_portal_business_ids)
  end
  
  def in_portal_business_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each {|val| _ids << val}
      write_attribute(:portal_business_ids, _ids.join(' '))
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess
      ids.each {|key, val| _ids << val}
      write_attribute(:portal_business_ids, _ids.join(' '))
    else
      write_attribute(:portal_business_ids, ids)
    end
  end
  
  def portal_business_items
    ids = portal_business_ids.to_s.split(' ').uniq
    return [] if ids.size == 0
    item = PortalGroup::Business.new
    item.and :id, 'IN', ids
    item.find(:all)
  end
  
  def portal_business_is(cate)
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
      self.and :portal_business_ids, 'REGEXP', "(^| )(#{ids.join('|')})( |$)"
    end
    return self
  end
end