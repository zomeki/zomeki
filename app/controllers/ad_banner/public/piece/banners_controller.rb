# encoding: utf-8
class AdBanner::Public::Piece::BannersController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = AdBanner::Piece::Banner.find_by_id(Page.current_piece.id)
    render :text => '' if @piece.nil? || @piece.content.banner_node.nil?
  end

  def index
    @banners = if @piece.groups.empty?
                 @piece.banners.published
               else
                 if @piece.group
                   @piece.group.banners.published
                 else
                   @piece.banners.published.select {|b| b.group.nil? }
                 end
               end

    @banners = case @piece.sort.last
               when 'ordered'
                 @banners.sort {|a, b| a.sort_no <=> b.sort_no }
               when 'random'
                 @banners.shuffle
               else
                 @banners
               end
  end
end
