class McTools
  # This class holds useful functions
  # user on Monitoring & Controlling plugin
  #$params = "Teste2"
  
  # return the plugin folder instalation
  def returnPluginFolderName
    if Rails.version.to_f >= 3.0
      File.dirname(__FILE__).gsub(File.join(Rails.root.to_s,'plugins'),'').split('/')[1] 
    else
      File.dirname(__FILE__).gsub(File.join(Rails.root.to_s,'vendor','plugins'),'').split('/')[1] 	
    end
  end
  
  # return subprojects ID
  def subProjects(id)
     Project.find_by_sql("select * from projects where parent_id = #{id.to_i}")
  end
    
  # return an array with the project and subprojects IDs
  def return_ids(id) 
    if (params[:rmcsearch] && !params[:rmcsearch][:only_main_project])
       array = Array.new
       array.push(id)  
       subprojects = subProjects(id)
       subprojects.each do |project|     
        array.push(return_ids(project.id))
       end
      
       return array.inspect.gsub("[","").gsub("]","").gsub("\\","").gsub("\"","")
    else
       return id
    end
  end

  # return total of tasks with closed flag false
  # done tasks
  def returnTotalOfClosedTasks(project_identifier)
    countTasks(project_identifier, true)
  end  
  # done tasks
  def returnTotalOfOpenTasks(project_identifier)
    countTasks(project_identifier, false)
  end
  
  def setParams(params)
    $params = params
  end
  
  def params
    $params
  end  
  
  #return conditions to query based on params
  def searchIssuesConditions
    if $params.has_key?(:rmcsearch)
      if $params[:rmcsearch].has_key?(:version)
        if $params[:rmcsearch][:version] > '0'
         "AND issues.fixed_version_id = #{$params[:rmcsearch][:version]}"
        end
      end 
    end
  end
  
  def searchIssuesByYear
    if $params.has_key?(:rmcsearch)
      if $params[:rmcsearch].has_key?(:year)
         if $params[:rmcsearch][:year] > '0'
           dateBegin = Date.new($params[:rmcsearch][:year].to_i, 1, 1)
           dateEnd = Date.new($params[:rmcsearch][:year].to_i, 12, 31)
           Rails.logger.warn "AND ((due_date is null AND start_date is null) 
                        OR (due_date is null AND start_date <= '#{dateEnd}') 
                        OR (start_date is null AND due_date >= '#{dateBegin}') 
                        OR (due_date >= #{dateBegin} AND start_date <= '#{dateEnd}'))"
           "AND ((due_date is null AND start_date is null) 
             OR (due_date is null AND start_date <= '#{dateEnd}') 
             OR (start_date is null AND due_date >= '#{dateBegin}') 
             OR (due_date >= '#{dateBegin}' AND start_date <= '#{dateEnd}'))"
         end
      end
    end
  end
  
  private
  #count tasks
  def countTasks(project_identifier, isClosed)
    #get main project
    project = Project.find_by_identifier(project_identifier)
    #get projects and sub projects
    stringSqlProjectsSubProjects = return_ids(project.id)
    total = 0
    Issue.find_by_sql(["select count(1) as totalclosedissue
                        from issues
                        where project_id in (#{stringSqlProjectsSubProjects})
                        and status_id in (select id from issue_statuses where is_closed = ?)",isClosed]).each do |t|
     
      total = t.totalclosedissue.to_i
    end
            
    total
  end      
  
end