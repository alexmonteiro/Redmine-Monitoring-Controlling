class HomeMonitoringControllingProjectController < ApplicationController
  unloadable

  menu_item :monitoring_controlling_project
  before_filter :find_optional_project
  before_filter :find_project, :authorize, :only => :index

  def find_project
    @project = Project.find_by_identifier(params[:id])
  end


  def index
    @project = Project.find_by_identifier(params[:id])
    @situacoes = IssueStatus.find_by_sql("SELECT *, 
                                          ((SELECT COUNT(1) FROM issues where project_id = #{@project.id} and status_id = issue_statuses.id)
                                          /
                                          (SELECT COUNT(1) FROM issues where project_id = #{@project.id}))*100 as percent,
                                          (SELECT COUNT(1) FROM issues where project_id = #{@project.id} and status_id = issue_statuses.id)                                           
                                          AS totalissues 
                                          FROM issue_statuses;")

    @managementissues = Issue.find_by_sql("select 1 as id, '#{t :manageable_label}' as typemanagement, count(1) as totalissues, (count(1)/#{@project.issues.count})*100 as percent
                                                 from issues where project_id = #{@project.id} and due_date is not null
                                                 union
                                                 select 2 as id, '#{t :unmanageable_label}' as typemanagement, count(1) as totalissues, (count(1)/#{@project.issues.count})*100 
                                                 from issues where project_id = #{@project.id} and due_date is null;")
    
    @issuesdelayedschart = Issue.find_by_sql("select 2 as id, '#{t :overdue_label}' as typeissue, count(1) as totalissuedelayed
                                                  from issues  
                                                  where project_id = #{@project.id}
                                                  and due_date is not null
                                                  and due_date < curdate()  
                                                  and status_id in (select id from issue_statuses where is_closed = 0)
                                                  union
                                                  select 1 as id, '#{t :delivered_label}' as typeissue, count(1) as totalissuedelayed
                                                  from issues  
                                                  where project_id = #{@project.id}
                                                  and due_date is not null
                                                  and due_date < curdate()
                                                  and status_id in (select id from issue_statuses where is_closed = 1) 
                                                  union
                                                  select 3 as id, '#{t :tobedelivered_label}' as typeissue, count(1) as totalissuedelayed
                                                  from issues  
                                                  where project_id = #{@project.id}
                                                  and due_date is not null
                                                  and due_date >= curdate()
                                                  and status_id in (select id from issue_statuses where is_closed = 0)
                                                  order by 1;")    
   
    @issuesdelayeds   =   Issue.find_by_sql("select *
                                                    from issues  
                                                    where project_id = #{@project.id}
                                                    and due_date is not null
                                                    and due_date < curdate()  
                                                    and status_id in (select id from issue_statuses where is_closed = 0);")


  end
end
