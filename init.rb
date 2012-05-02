require 'redmine'

Redmine::Plugin.register :redmine_monitoring_controlling do
  name 'Redmine Monitoramento & Controle'
  author 'Alexander Monteiro'
  description 'Este plugin foi criado para auxiliar no Monitoramento e Controle dos projetos no redmine através de uma visualização gráfica das tarefas e sua execução.\n
               This plugin is a graphic tool to Monitoring and Controlling projects on redmine'
  version '0.0.2'
  url 'http://alexmonteiro.github.com/Redmine-Monitoring-Controlling/'
  author_url 'http://www.alexandermonteiro.com.br'
  
  project_module :monitoring_controlling_project do
      permission :view_home_monitoring_controlling, :home_monitoring_controlling_project => :index
      permission :view_mc_time_mgmt_project, :mc_time_mgmt_project => :index
  end
  
  menu :project_menu, :monitoring_controlling_project, { :controller => 'home_monitoring_controlling_project', :action => 'index' }, :caption => :monitoring_controlling_title
    
end
