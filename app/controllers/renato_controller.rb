class RenatoController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project, :authorize
  menu_item :monitoring_controlling_project

  def index

  end

  private
  def find_project
    @project=Project.find(params[:id])
  end
end