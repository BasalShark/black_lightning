# == Schema Information
#
# Table name: admin_proposals_proposals
#
# *id*::             <tt>integer, not null, primary key</tt>
# *call_id*::        <tt>integer</tt>
# *show_title*::     <tt>string(255)</tt>
# *publicity_text*:: <tt>text(65535)</tt>
# *proposal_text*::  <tt>text(65535)</tt>
# *created_at*::     <tt>datetime, not null</tt>
# *updated_at*::     <tt>datetime, not null</tt>
# *late*::           <tt>boolean</tt>
# *approved*::       <tt>boolean</tt>
# *successful*::     <tt>boolean</tt>
#--
# == Schema Information End
#++

require 'test_helper'

class Admin::Proposals::ProposalTest < ActiveSupport::TestCase
  setup do
    @call = FactoryBot.create(:proposal_call, submission_deadline: DateTime.now.advance(days: 5), question_count: 3)
    @proposal = FactoryBot.create(:proposal, call: @call)
  end

  test 'instantiate_answers' do
    @proposal.questions.clear

    remaining_question = @call.questions.first
    @proposal.questions << remaining_question

    new_question_count = remaining_question.answers.where(answerable: @proposal).any? ? 2 : 3

    assert_difference '@proposal.answers.count', new_question_count do
      # 2 = 3 answers on the call - 1 already added
      assert_difference '@proposal.questions.count', 2 do
        @proposal.instantiate_answers!
      end
    end
  end

  test 'has_debtors' do
    assert_not_equal @proposal.users.first, @proposal.users.last
    # Add a debt a few days before the deadline editing. This user should be in debt.
    _not_counting_debt = FactoryBot.create(:staffing_debt, user: @proposal.users.first, due_by: @proposal.call.editing_deadline.to_date.advance(days: 1))

    assert_not @proposal.has_debtors

    _counting_debt = FactoryBot.create(:maintenance_debt, user: @proposal.users.last, due_by: @proposal.call.editing_deadline.to_date.advance(days: -3))
    assert @proposal.has_debtors
  end

  test 'convert unsuccesful proposal to show' do
    @proposal.update_attribute(:successful, false)

    exception = assert_raise(ArgumentError) do
      @proposal.convert_to_show
    end

    assert_equal('This proposal was not successful', exception.message)
  end

  test 'convert invalid proposal to show' do
    @proposal.update_attribute(:successful, true)
    @proposal.update_attribute(:show_title, nil)

    assert_raises ActiveRecord::RecordNotSaved do
      @proposal.convert_to_show
    end
  end

  test 'convert succesful proposal to show' do
    @proposal.update_attribute(:successful, true)

    @proposal.convert_to_show

    show = Show.find_by_name(@proposal.show_title)

    assert show.present?

    assert_equal @proposal.show_title, show.name
    assert_equal @proposal.publicity_text, show.publicity_text

    assert_not_nil show.slug

    assert_equal 'TBC', show.author
    assert_equal 'TBC', show.price

    assert_equal Date.current, show.start_date
    assert_equal Date.current, show.end_date
    assert_not show.is_public

    assert_equal @proposal.user_ids.sort, show.user_ids.sort
    assert_equal @proposal, show.proposal

    assert_equal venues(:unknown), show.venue

    assert @proposal.reload.successful
  end

  test 'labels for successful proposal with debtors' do
    @proposal.approved = true
    @proposal.successful = true
    _debt = FactoryBot.create(:staffing_debt, user: @proposal.users.first, due_by: @call.editing_deadline.advance(days: -1))
    expected_labels = "<span class=\"badge bg-success\">Successful</span>\n<span class=\"badge bg-danger\">Has Debtors</span>"

    assert_equal expected_labels, @proposal.labels(false)
  end

  test 'labels for rejected proposal that was late with pull right' do
    @proposal.late = true
    @proposal.approved = false

    expected_labels = "<div class=\"float-right\"><span class=\"badge bg-danger\">Rejected</span>\n<span class=\"badge bg-danger\">Late</span></div>"

    assert_equal expected_labels, @proposal.labels(true)
  end

  test 'labels for proposal awaiting approval with debtors that was late' do
    @proposal.approved = nil
    @proposal.successful = nil
    @proposal.late = true
    _debt = FactoryBot.create(:staffing_debt, user: @proposal.users.first, due_by: @call.editing_deadline.advance(days: -1))

    expected_labels = "<span class=\"badge bg-warning text-dark\">Waiting for Approval</span>\n<span class=\"badge bg-danger\">Late</span>\n<span class=\"badge bg-danger\">Has Debtors</span>"

    assert_equal expected_labels, @proposal.labels(false)
  end

  test 'labels for approved proposal' do
    @proposal.approved = true
    @proposal.successful = nil

    expected_labels = '<span class="badge bg-success">Approved</span>'

    assert_equal expected_labels, @proposal.labels(false)
  end

  test 'labels for unsuccessful proposal with pull right' do
    @proposal.successful = false

    expected_labels = "<div class=\"float-right\"><span class=\"badge bg-danger\">Unsuccessful</span></div>"

    assert_equal expected_labels, @proposal.labels(true)
  end
end
