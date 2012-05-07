class McHumanResourceMgmtProjectController < ApplicationController
  unloadable

  menu_item :monitoring_controlling_project
  before_filter :find_optional_project
  before_filter :find_project, :authorize


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
    
=begin
    @statusesByAssigneds = Issue.find_by_sql("select assigned_to_id, (select firstname from users where id = assigned_to_id) as assigned_name,
           status_id, name as status,
         count(1) as totalAssignedByStatuses 
    from issues, issue_statuses 
    where project_id in (#{stringSqlProjectsSubPorjects})
    and   issue_statuses.id = status_id
    group by assigned_to_id, assigned_name, status_id, status 
    order by 2,3;")
=end

  @statusesByAssigneds = Issue.find_by_sql("select assigned_to_id, (select firstname from users where id = assigned_to_id) as assigned_name,
                                            issue_statuses.id, issue_statuses.name, 
                                       	    (select COUNT(1) 
                                             from issues i 
                                             where i.project_id in (#{stringSqlProjectsSubPorjects})
                                             and ((i.assigned_to_id = issues.assigned_to_id and i.assigned_to_id is not null)or(i.assigned_to_id is null and issues.assigned_to_id is null)) and i.status_id = issue_statuses.id) as totalAssignedByStatuses
                                             from issues, issue_statuses  
                                             where project_id in (#{stringSqlProjectsSubPorjects}) 
                                             group by assigned_to_id, assigned_name, issue_statuses.id, issue_statuses.name
                                             order by 2,3;")  
    
    
  end

end