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
    if (!params[:rmcsearch] || (params[:rmcsearch] && !params[:rmcsearch][:only_main_project]))
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

  # return a set of relevant years for a project and its subprojects
  def relevant_years(project_id)
    years = SortedSet.new
    actualYear = Date.today.year
    issues = Issue.where("project_id = ?", project_id)
    issues.each do |i|
      if(i.start_date != nil && i.due_date != nil)
        start_year = i.start_date.year
        end_year = i.due_date.year
        for y in (start_year..end_year)
          years.add(y)
        end
      elsif(i.start_date != nil && i.due_date == nil) 
        start_year = i.start_date.year
        if(start_year > actualYear)
          years.add(start_year)
        else
          for y in (start_year..actualYear)
            years.add(y)
          end
        end
      elsif(i.start_date == nil && i.due_date != nil)
        end_year = i.due_date.year
        if(end_year < actualYear)
          years.add(end_year)
        else
          for y in (actualYear..end_year)
            years.add(y)
          end
        end 
      end
    end
    if((!params[:rmcsearch]) || (params[:rmcsearch] && !params[:rmcsearch][:only_main_project]))
      subprojects = subProjects(project_id)
      subprojects.each do |p|
        years.merge(relevant_years(p.id))
      end
    end
    return years
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
    conditions = ""
    if $params.has_key?(:rmcsearch)
      if $params[:rmcsearch].has_key?(:version)
        if $params[:rmcsearch][:version] > '0'
         conditions += "AND issues.fixed_version_id = #{$params[:rmcsearch][:version]}"
        end
      end 
      if $params[:rmcsearch].has_key?(:year)
         if $params[:rmcsearch][:year] > '0'
           dateBegin = Date.new($params[:rmcsearch][:year].to_i, 1, 1)
           dateEnd = Date.new($params[:rmcsearch][:year].to_i, 12, 31)
           conditions += " AND ((due_date is null AND start_date is null) 
             OR (due_date is null AND start_date <= '#{dateEnd}') 
             OR (start_date is null AND due_date >= '#{dateBegin}') 
             OR (due_date >= '#{dateBegin}' AND start_date <= '#{dateEnd}'))"
         end
      end
    end
    return conditions
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