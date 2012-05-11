class ApplicationController < ActionController::Base
  before_filter :getPluginFolderName
  protect_from_forgery
  
  def getPluginFolderName
      @PluginFolderName = 'redmine_monitoring_controlling' unless @PluginFolderName = File.dirname(__FILE__).gsub(File.join(Rails.root.to_s,'vendor','plugins'),'').split('/')[1]    
  end
  
end