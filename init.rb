require 'redmine'

Redmine::Plugin.register :redmine_monitoring_controlling do
  name 'Redmine Monitoramento & Controle'
  author 'Alexander Monteiro'
  description 'Este plugin foi criado para auxiliar no Monitoramento e Controle dos projetos no redmine através de uma visualização gráfica das tarefas e sua execução.'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://www.alexandermonteiro.com.br'
  
  project_module :monitoring_controlling_project do
      permission :view_home_monitoring_controlling, :home_monitoring_controlling_project => :index
  end
  
  menu :project_menu, :monitoring_controlling_project, { :controller => 'home_monitoring_controlling_project', :action => 'index' }, :caption => :monitoring_controlling_title
end
