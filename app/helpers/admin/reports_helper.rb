module Admin::ReportsHelper
  def list_reports
    reports = Admin::ReportsController.action_methods
    reports = reports.map { |r| r.to_s }
    reports.delete('index')
    reports.delete('authorize_backend!')

    return reports
  end
end
