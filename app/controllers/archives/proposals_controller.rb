class Archives::ProposalsController < AdminController
  def index
    authorize! :index, Admin::Proposals::Proposal

    @title = 'Proposal Archive'

    # The next chapter in hacky solutions to accessible by errors.
    # Because accessible_by and the search both need the team_members table, it errors when you search for a person name.

    @q = Admin::Proposals::Proposal.ransack(params[:q])

    @proposals = @q.result(distinct: true)
    result_ids = @proposals.ids

    @proposals = Admin::Proposals::Proposal.where(id: result_ids).accessible_by(current_ability)
    call_ids = @proposals.collect(&:call_id).uniq

    @calls = Admin::Proposals::Call.where(id: call_ids)
                                   .reorder('submission_deadline DESC')
                                   .paginate(page: params[:page], per_page: 20)

    @proposals = @proposals.where(call_id: @calls.ids)
                           .includes(:call, team_members: [user: [:admin_maintenance_debts, :admin_staffing_debts]])
                           .order('admin_proposals_calls.submission_deadline DESC')
                           .group_by(&:call)
  end
end
