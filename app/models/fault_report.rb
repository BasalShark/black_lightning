# == Schema Information
#
# Table name: fault_reports
#
# *id*::             <tt>integer, not null, primary key</tt>
# *item*::           <tt>string(255)</tt>
# *description*::    <tt>text(65535)</tt>
# *severity*::       <tt>integer, default("annoying")</tt>
# *status*::         <tt>integer, default("reported")</tt>
# *reported_by_id*:: <tt>integer</tt>
# *fixed_by_id*::    <tt>integer</tt>
# *created_at*::     <tt>datetime, not null</tt>
# *updated_at*::     <tt>datetime, not null</tt>
#--
# == Schema Information End
#++
class FaultReport < ApplicationRecord
  validates :item, :description, presence: true

  belongs_to :reported_by,  class_name: 'User'
  belongs_to :fixed_by,     class_name: 'User', optional: true

  enum severity: %I[annoying probably_worth_fixing show_impeding dangerous]
  enum status: %I[reported in_progress cant_fix wont_fix on_hold completed]

  def reported_by_name
    return reported_by.try(:name) || 'Unknown'
  end

  def fixed_by_name
    return fixed_by.try(:name) || 'Unknown'
  end

  def css_class
    case status.to_sym
    when :in_progress, :on_hold
      return 'table-warning'
    when :cant_fix, :wont_fix
      return 'table-danger'
    when :completed
      return 'table-success'
    else
      return ''
    end
  end
end
