Redmine::Plugin.register :redmine_calculate_announced_estimation do
  name 'Redmine Calculate Announced Estimation plugin'
  author 'Bilel KEDIDI'
  description 'This plugin will create a virtual field in Issue page'
  version '0.0.1'
  author_url 'http://github.com/bilel-kedidi'

  settings :default => {
        'announced_estimation'  => 'announced estimation'
    }, :partial => 'redmine_calculation/setting'

  # project_module :redmine_calculate_announced_estimation do
  #   permission :show_calculation_of_client_estimation, :calculate_estimation => :index
  # end
end

Rails.application.config.to_prepare do
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_show_details_bottom(context = {})
      issue = context[:issue]
      announced_estimation = Setting.plugin_redmine_calculate_announced_estimation['announced_estimation']
      if check_estimation_exist?(issue, announced_estimation)
        cf = issue.custom_field_values.select{|cf| cf.custom_field.name == announced_estimation}.first
        estimation = 0
        estimation = cf.value if cf
        total_times = issue.time_entries.map(&:hours).sum.round(2)
        s = "<tr>\n"
        s += "<th> Rest-to-annuncement</th><td >#{estimation.to_f - total_times}</td>\n"
        s += '</tr>'
        s
      end
    end
    def check_estimation_exist?(issue, announced_estimation)
      if announced_estimation.present? and CustomField.where(type: "IssueCustomField").where(name: announced_estimation).present?
          if issue.visible_custom_field_values.select{|cf| cf.custom_field.name == announced_estimation}.present?
            return true
          end
        false
      end
      false
    end

  end
end

