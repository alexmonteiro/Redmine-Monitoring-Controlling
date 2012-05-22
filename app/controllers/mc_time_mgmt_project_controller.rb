class McTimeMgmtProjectController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project, :authorize
  menu_item :redmine_monitoring_controlling

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


    @issuesSpentHours = Issue.find_by_sql("select issues.due_date, sum(issues.estimated_hours) as estimated_hours, 
                                                                 (select sum(i.estimated_hours) 
                                                                  from issues i 
                                                                  where i.project_id in (#{stringSqlProjectsSubPorjects})
                                                                  and i.due_date is not null 
                                                                  and i.due_date <= issues.due_date) as sumestimatedhours,
                                                                  (select sum(hours) from time_entries where project_id in (#{stringSqlProjectsSubPorjects}) and created_on <= issues.due_date ) as sumspenthours
                                         from issues 
                                         where issues.project_id in (#{stringSqlProjectsSubPorjects})
                                         and due_date is not null   
                                         group by issues.due_date  
                                        order by due_date;")    
                                      

  end

  private
  def find_project
    @project=Project.find(params[:id])
  end


end