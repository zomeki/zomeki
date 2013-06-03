# encoding: utf-8
class Cms::Piece::SnsPart < Cms::Piece
  SETTING_KEYS = [:twitter, :g_plusone, :fb_like]
  SETTING_NAMES = {twitter: 'Twitter ツイート', g_plusone: 'Google +1', fb_like: 'Facebook いいね！'}.with_indifferent_access
end
