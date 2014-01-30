class HomeMonitoringControllingProjectController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project, :authorize
  menu_item :redmine_monitoring_controlling

  def index
    @subprojects = @project.descendants
    @allprojects = @subprojects.map(&:id) + Project.where(:identifier => params[:id]).select(:id).map(&:id) || []
    @all_project_issues = Issue.where(:project_id => @allprojects)
    
    # total issues from the project and subprojects
    @totalIssues = Issue.where(:project_id => @allprojects).count
    
    #get count of issues by category
    @issuesbycategory = IssueStatus.includes(:issue).where(:issue => {:project_id => @allprojects}).group('issue_statuses.name, issue_statuses.position')
    
    #get statuses by main project and subprojects
    if @totalIssues > 0 
      @statuses = IssueStatus.includes(:issue).where(:issue => { :project_id => @allprojects}).group(:id).select('issue_statuses.*, (COUNT(*) / #{@totalIssues}) * 100 as percent, COUNT(*) as totalissues')
    else
      @statuses = nil
    end                                          

    #get management issues by main project
    @managementissues = Issue.where("id IN (#{@allprojects.join(',')}) and due_date is not null").select("1 as id, '#{t :manageable_label}' as typemanagement, count(*) as totalissues")
    @managementissues += Issue.where(:id => @allprojects, :due_date => nil).select("2 as id, '#{t :unmanageable_label}' as typemanagement, count(*) as totalissues")

    @closedIssueStatus = IssueStatus.where(:is_closed => true).map(&:id)
    @openIssueStatus = IssueStatus.where(:is_closed => false).map(&:id)
    #get overdue issues for char by by project and subprojects
    @overdueissueschart = Issue.where("project_id IN(#{@allprojects.join(',')}) AND due_date IS NOT NULL and due_date < '#{Date.today}'
				    AND status_id IN (#{@openIssueStatus.join(',')})").select("1 as id, '#{t :delivered_label}' as typeissue, count(*) as totalissuedelayed")
    @overdueissueschart += Issue.where("project_id IN(#{@allprojects.join(',')}) AND due_date IS NOT NULL and due_date < '#{Date.today}'
				    AND status_id IN (#{@closedIssueStatus.join(',')})").select("2 as id, '#{t :overdue_label}' as typeissue, count(*) as totalissuedelayed")
    @overdueissueschart += Issue.where("project_id IN(#{@allprojects.join(',')}) AND due_date IS NOT NULL and due_date >= '#{Date.today}'
				    AND status_id IN (#{@closedIssueStatus.join(',')})").select("3 as id, '#{t :tobedelivered_label}' as typeissue, count(*) as totalissuedelayed")

    #get overdueissues by project and subprojects
    @overdueissues = Issue.where("project_id IN(#{@allprojects.join(',')}) AND due_date IS NOT NULL and due_date < '#{Date.today}'
				    AND status_id IN (#{@closedIssueStatus.join(',')})").order(:due_date)

    #get unmanagement issues by main project
    @unmanagementissues = Issue.where(:project_id => @allprojects, :due_date => nil).order(:id)
  end

  private
  def find_project
    @project=Project.find(params[:id])
  end
end
