class HomeMonitoringControllingProjectController < ApplicationController
  unloadable

  menu_item :monitoring_controlling_project
  before_filter :find_optional_project
  before_filter :find_project, :authorize, :only => :index
  

  def find_project
    @project = Project.find_by_identifier(params[:id])
  end

  def subProjects(id)
     Project.find_by_sql("select * from projects where parent_id = #{id.to_i}")
  end
    
  def return_ids(id)       
     array = Array.new
     array.push(id)  
     subprojects = subProjects(id)
     subprojects.each do |project|     
      array.push(return_ids(project.id))
     end
      
     return array
  end
    
  def index
    #get main project
    @project = Project.find_by_identifier(params[:id])
    
    #get projects and sub projects
    stringSqlProjectsSubPorjects = return_ids(@project.id).inspect.gsub("[","").gsub("]","")
    #stringSqlProjectsSubPorjects = return_ids(@project.id).inspect.gsub("[","").gsub("]","")
    @projects_subprojects = Project.find_by_sql("select * from projects where id in (#{stringSqlProjectsSubPorjects});")
    @all_project_issues = Issue.find_by_sql("select * from issues where project_id in (#{stringSqlProjectsSubPorjects});")
    
    #get statuses by main project
    #@statuses = IssueStatus.find_by_sql("SELECT *, 
    #                                      ((SELECT COUNT(1) FROM issues where project_id = #{@project.id} and status_id = issue_statuses.id)
    #                                      /
    #                                      (SELECT COUNT(1) FROM issues where project_id = #{@project.id}))*100 as percent,
    #                                      (SELECT COUNT(1) FROM issues where project_id = #{@project.id} and status_id = issue_statuses.id)                                           
    #                                      AS totalissues 
    #                                      FROM issue_statuses;")
    #                                      #get statuses by main project

    #get statuses by main project and subprojects
    @statuses = IssueStatus.find_by_sql("SELECT *, 
                                          ((SELECT COUNT(1) FROM issues where project_id in (#{stringSqlProjectsSubPorjects}) and status_id = issue_statuses.id)
                                          /
                                          (SELECT COUNT(1) FROM issues where project_id in (#{stringSqlProjectsSubPorjects})))*100 as percent,
                                          (SELECT COUNT(1) FROM issues where project_id in (#{stringSqlProjectsSubPorjects}) and status_id = issue_statuses.id)                                           
                                          AS totalissues 
                                          FROM issue_statuses;")

                                          
    #get management issues by main project
    #@managementissues = Issue.find_by_sql("select 1 as id, '#{t :manageable_label}' as typemanagement, count(1) as totalissues
    #                                             from issues where project_id = #{@project.id} and due_date is not null
    #                                             union
    #                                             select 2 as id, '#{t :unmanageable_label}' as typemanagement, count(1) as totalissues
    #                                             from issues where project_id = #{@project.id} and due_date is null;")

    #get management issues by main project
    @managementissues = Issue.find_by_sql("select 1 as id, '#{t :manageable_label}' as typemanagement, count(1) as totalissues
                                                from issues where project_id in (#{stringSqlProjectsSubPorjects}) and due_date is not null
                                                union
                                                select 2 as id, '#{t :unmanageable_label}' as typemanagement, count(1) as totalissues
                                                from issues where project_id in (#{stringSqlProjectsSubPorjects}) and due_date is null;")
                                                 
    #get overdue issues for chart by main project
    # @overdueissueschart = Issue.find_by_sql("select 2 as id, '#{t :overdue_label}' as typeissue, count(1) as totalissuedelayed
    #                                              from issues  
    #                                              where project_id = #{@project.id}
    #                                              and due_date is not null
    #                                              and due_date < curdate()  
    #                                              and status_id in (select id from issue_statuses where is_closed = 0)
    #                                              union
    #                                              select 1 as id, '#{t :delivered_label}' as typeissue, count(1) as totalissuedelayed
    #                                              from issues  
    #                                              where project_id = #{@project.id}
    #                                              and due_date is not null
    #                                              and due_date < curdate()
    #                                              and status_id in (select id from issue_statuses where is_closed = 1) 
    #                                              union
    #                                              select 3 as id, '#{t :tobedelivered_label}' as typeissue, count(1) as totalissuedelayed
    #                                              from issues  
    #                                              where project_id = #{@project.id}
    #                                              and due_date is not null
    #                                              and due_date >= curdate()
    #                                              and status_id in (select id from issue_statuses where is_closed = 0)
    #                                              order by 1;")    

    #get overdue issues for char by by project and subprojects
    @overdueissueschart = Issue.find_by_sql("select 2 as id, '#{t :overdue_label}' as typeissue, count(1) as totalissuedelayed
                                                  from issues  
                                                  where project_id in (#{stringSqlProjectsSubPorjects})
                                                  and due_date is not null
                                                  and due_date < curdate()  
                                                  and status_id in (select id from issue_statuses where is_closed = 0)
                                                  union
                                                  select 1 as id, '#{t :delivered_label}' as typeissue, count(1) as totalissuedelayed
                                                  from issues  
                                                  where project_id in (#{stringSqlProjectsSubPorjects})
                                                  and due_date is not null
                                                  and due_date < curdate()
                                                  and status_id in (select id from issue_statuses where is_closed = 1) 
                                                  union
                                                  select 3 as id, '#{t :tobedelivered_label}' as typeissue, count(1) as totalissuedelayed
                                                  from issues  
                                                  where project_id in (#{stringSqlProjectsSubPorjects})
                                                  and due_date is not null
                                                  and due_date >= curdate()
                                                  and status_id in (select id from issue_statuses where is_closed = 0)
                                                  order by 1;")    

   
    # get overdueissues by project
    #         @overdueissues   =   Issue.find_by_sql("select *
    #                                                        from issues  
    #                                                        where project_id = #{@project.id}
    #                                                        and due_date is not null
    #                                                        and due_date < curdate()  
    #                                                         and status_id in (select id from issue_statuses where is_closed = 0);")

    #get overdueissues by project and subprojects
    @overdueissues   =   Issue.find_by_sql("select *, DATEDIFF(curdate(), due_date) as overduedays
                                                    from issues  
                                                    where project_id in (#{stringSqlProjectsSubPorjects})
                                                    and due_date is not null
                                                    and due_date < curdate()  
                                                    and status_id in (select id from issue_statuses where is_closed = 0)
                                                    order by overduedays desc;")
                                                    

                                                                          
  
  
  end
end
