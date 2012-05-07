ActionController::Routing::Routes.draw do |map|
  map.connect '/home_monitoring_controlling_project/index/:id', :controller => 'home_monitoring_controlling_project', :action => 'index'
  map.connect '/mc_time_mgmt_project/index/:id', :controller => 'mc_time_mgmt_project', :action => 'index'
  map.connect '/mc_human_resource_project/index/:id', :controller => 'mc_human_resource_mgmt_project', :action => 'index'
end