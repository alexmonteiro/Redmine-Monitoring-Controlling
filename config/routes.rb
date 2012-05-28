if Rails.version.to_f >= 3.0
  match 'home_monitoring_controlling_project/index/:id', :to => 'home_monitoring_controlling_project#index', :via => :get
  match 'mc_time_mgmt_project/index/:id', :to => 'mc_time_mgmt_project#index', :via => :get
  match 'mc_human_resource_project/index/:id', :to => 'mc_human_resource_mgmt_project#index', :via => :get
else # Routes for older Rails routes
  ActionController::Routing::Routes.draw do |map|
   map.connect '/home_monitoring_controlling_project/index/:id', :controller => 'home_monitoring_controlling_project', :action => 'index'
   map.connect '/mc_time_mgmt_project/index/:id', :controller => 'mc_time_mgmt_project', :action => 'index'
   map.connect '/mc_human_resource_project/index/:id', :controller => 'mc_human_resource_mgmt_project', :action => 'index'
  end
end