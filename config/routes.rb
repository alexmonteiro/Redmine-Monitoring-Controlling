ActionController::Routing::Routes.draw do |map|
  map.connect '/home_monitoring_controlling_project/index/:id', :controller => 'home_monitoring_controlling_project', :action => 'index'
  map.connect '/home_monitoring_controlling_project/teste/:id', :controller => 'home_monitoring_controlling_project', :action => 'teste'
end