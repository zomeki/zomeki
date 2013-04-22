# encoding: utf-8
class AdBanner::Content::Banner < Cms::Content
  default_scope where(model: 'AdBanner::Banner')
end
