class GpArticle::Public::Piece::MonthlyArchivesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::MonthlyArchive.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece
  end

  def index
    @monthly_num_docs = @piece.content.public_docs
                              .group("DATE_FORMAT(display_published_at,'%Y-%m')").count
  end
end
