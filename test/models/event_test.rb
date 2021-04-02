# == Schema Information
#
# Table name: events
#
# *id*::                     <tt>integer, not null, primary key</tt>
# *name*::                   <tt>string(255)</tt>
# *tagline*::                <tt>string(255)</tt>
# *slug*::                   <tt>string(255)</tt>
# *publicity_text*::         <tt>text(65535)</tt>
# *members_only_text*::      <tt>text(65535)</tt>
# *xts_id*::                 <tt>integer</tt>
# *created_at*::             <tt>datetime, not null</tt>
# *updated_at*::             <tt>datetime, not null</tt>
# *is_public*::              <tt>boolean</tt>
# *image_file_name*::        <tt>string(255)</tt>
# *image_content_type*::     <tt>string(255)</tt>
# *image_file_size*::        <tt>integer</tt>
# *image_updated_at*::       <tt>datetime</tt>
# *start_date*::             <tt>date</tt>
# *end_date*::               <tt>date</tt>
# *venue_id*::               <tt>integer</tt>
# *season_id*::              <tt>integer</tt>
# *author*::                 <tt>string(255)</tt>
# *type*::                   <tt>string(255)</tt>
# *price*::                  <tt>string(255)</tt>
# *spark_seat_slug*::        <tt>string(255)</tt>
# *maintenance_debt_start*:: <tt>date</tt>
# *staffing_debt_start*::    <tt>date</tt>
# *proposal_id*::            <tt>integer</tt>
#--
# == Schema Information End
#++
require 'test_helper'

class EventTest < ActionView::TestCase
  include TimeHelper

  setup do
    @event = FactoryBot.create(:event)
  end

  test 'last_event' do
    old_season = FactoryBot.create(:show, start_date: @event.start_date.advance(years: -3))
    last_workshop = FactoryBot.create(:workshop, start_date: Date.today.advance(weeks: -3), is_public: true)
    assert_equal last_workshop, Event.last_event
    assert_equal last_workshop, Workshop.last_event
  end

  test 'selection_collection' do
    assert_equal [[@event.name, @event.id]], Event.selection_collection
  end

  test 'this_year' do
    this_year_show = FactoryBot.create(:show, start_date: Date.today)
    old_show = FactoryBot.create(:show, start_date: @event.start_date.advance(years: -3))
    future_workshop = FactoryBot.create(:workshop, start_date: Date.today.advance(years: 1))

    assert_includes Event.this_year, this_year_show
    assert_not_includes Event.this_year, old_show
    assert_not_includes Event.this_year, future_workshop
  end

  test 'thumb_image_url' do
    event = FactoryBot.create(:event, attach_image: false)
    assert_includes event.thumb_image_url, 'active_storage_default-events-'
  end

  test 'slideshow_image_url' do
    event = FactoryBot.create(:event, attach_image: false)
    assert_includes event.slideshow_image_url, 'active_storage_default-events-'
  end

  test 'date_range' do
    assert_equal time_range_string(@event.start_date, @event.end_date, true), @event.date_range(true)
  end

  test 'simultaneous seasons' do
    season = FactoryBot.create(:season)
    assert_includes season.simultaneous_seasons, season
    show = FactoryBot.create(:show, start_date: season.end_date.advance(days: -1))
    assert_includes show.simultaneous_seasons, season
  end

  test 'possible proposals for new event and existing event' do
    show = FactoryBot.build(:workshop, attach_proposal: false)

    long_ago_proposal = FactoryBot.create(:proposal, submission_deadline: show.start_date.advance(years: -5), successful: true)
    current_proposal = FactoryBot.create(:proposal, submission_deadline: show.start_date.advance(days: -5), successful: true)
    far_future_proposal = FactoryBot.create(:proposal, submission_deadline: show.start_date.advance(years: 5), successful: true)

    unsuccessful_proposal = FactoryBot.create(:proposal, submission_deadline: show.start_date.advance(days: -5), successful: false)

    assert_includes show.possible_proposals, long_ago_proposal
    assert_includes show.possible_proposals, current_proposal
    assert_includes show.possible_proposals, far_future_proposal
    assert_not_includes show.possible_proposals, unsuccessful_proposal

    show.save

    assert_not_includes show.possible_proposals, long_ago_proposal
    assert_includes show.possible_proposals, current_proposal
    assert_not_includes show.possible_proposals, far_future_proposal
    assert_not_includes show.possible_proposals, unsuccessful_proposal
  end

  test 'possible proposals for existing event with proposal attached' do
    show = FactoryBot.create(:show, attach_proposal: false)

    current_proposal = FactoryBot.create(:proposal, submission_deadline: show.start_date.advance(days: -5), successful: true)
    far_future_proposal = FactoryBot.create(:proposal, submission_deadline: show.start_date.advance(years: 5), successful: true)

    show.proposal = far_future_proposal

    assert_includes show.possible_proposals, current_proposal
    assert_includes show.possible_proposals, far_future_proposal
  end

  test 'as_json' do
    @event.update!(venue: venues(:one), season: FactoryBot.create(:season))

    json = @event.as_json(include: [:season])

    assert json.is_a? Hash
    assert json.key? 'venue'
    assert json.key? 'season'
  end

  test 'sets default members-only text field' do
    event = Event.new

    assert_equal 'This is the default text for the members-only text field.', event.members_only_text
  end
end
