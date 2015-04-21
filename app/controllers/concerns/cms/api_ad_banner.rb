module Cms::ApiAdBanner
  extend ActiveSupport::Concern

  included do
  end

  def ad_banner(path:, version:)
    case path.shift
    when 'piece_banners'; ad_banner_piece_banners(path: path, version: version)
    else render_404
    end
  end

  def ad_banner_piece_banners(path:, version:)
    return render_404 if path.present?
    return render_405 unless request.get?
    return render_404 unless version == '20150401'

    piece = AdBanner::Piece::Banner.where(id: params[:piece_id]).first
    return render(json: {}) unless piece && piece.content.public_node

    banners = if piece.groups.empty?
                piece.banners.published
              else
                if piece.group
                  piece.group.banners.published
                else
                  piece.banners.published.select{|b| b.group.nil? }
                end
              end

    banners = case piece.sort.last
              when 'ordered'
                banners.sort{|a, b| a.sort_no <=> b.sort_no }
              when 'random'
                banners.shuffle
              else
                banners
              end

    result = {}

    result[:upper_text] = piece.upper_text.presence
    result[:lower_text] = piece.lower_text.presence
    result[:banners] = banners.map do |banner|
                           {title: banner.title, target: banner.target,
                            url: banner.link_uri, image_url: banner.image_uri}
                         end

    render json: result
  end
end
