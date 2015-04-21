module Cms::ApiRank
  extend ActiveSupport::Concern

  include Rank::Controller::Rank

  included do
  end

  def rank(path:, version:)
    case path.shift
    when 'piece_ranks'; rank_piece_ranks(path: path, version: version)
    else render_404
    end
  end

  def rank_piece_ranks(path:, version:)
    return render_404 if path.present?
    return render_405 unless request.get?
    return render_404 unless version == '20150401'

    content = Rank::Content::Rank.where(id: params[:content_id]).first
    piece = content.pieces.where(id: params[:piece_id]).first if content
    return render(json: {}) unless content && piece

    term = piece.ranking_term
    target = piece.ranking_target
    ranks = rank_datas(piece.content, term, target, piece.display_count, piece.category_option)

    result = {}
    result[:ranks] = ranks.map do |rank|
                         {title: rank.page_title,
                            url: "#{request.scheme}://#{rank.hostname}#{rank.page_path}",
                          count: piece.show_count == 0 ? nil : rank.accesses}
                       end
    result[:more] = if (body = piece.more_link_body).present? && (url = piece.more_link_url).present?
                      {body: body, url: url}
                    end

    render json: result
  end
end
