ActionController::Routing::Routes.draw do |map|
  map.connect '/home_monitoring_controlling_project/index/:id', :controller => 'home_monitoring_controlling_project', :action => 'index'
end