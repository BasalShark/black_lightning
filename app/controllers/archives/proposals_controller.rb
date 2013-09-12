class Archives::ProposalsController < ArchivesController
  before_filter :authenticate_user!

  def index
    @q = Admin::Proposals::Proposal.joins(:call)
                                   .where({ :admin_proposals_calls => { :archived => true }, :approved => true })
                                   .search(params[:q])
    @proposals = @q.result(distinct: true)
    @proposals = @proposals.group_by { |p| p.call }
  end
end