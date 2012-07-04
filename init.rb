# encoding: UTF-8
require 'redmine'

Redmine::Plugin.register :redmine_monitoring_controlling do
  name 'Redmine (Monitoring & Controlling | Monitoramento & Controle)'
  author 'Alexander Monteiro'
  description "Este plugin foi criado para auxiliar no Monitoramento e Controle dos projetos no redmine através de uma visualização gráfica das tarefas e sua execução.\n
               This plugin is a graphic tool to Monitoring and Controlling projects on redmine."
  version '0.1.1'
  url 'http://alexmonteiro.github.com/redmine_monitoring_controlling/'
  author_url 'http://www.alexandermonteiro.com.br'
  
  #Settings page of plugin
  #settings :default => {'redmine_monitoring_controlling_setting' => 'value', 'foo'=>'bar'}, :partial => 'settings/redmine_monitoring_controlling_settings'
  
  project_module :monitoring_controlling_project do
      permission :view_home_monitoring_controlling, {:home_monitoring_controlling_project => [:index]}
      permission :view_mc_time_mgmt_project, {:mc_time_mgmt_project => [:index]}
      permission :view_mc_human_resource_mgmt_project, {:mc_human_resource_mgmt_project => [:index]}
  end

  menu :project_menu, :redmine_monitoring_controlling, { :controller => 'home_monitoring_controlling_project', :action => 'index' }, :caption => :monitoring_controlling_title

end

