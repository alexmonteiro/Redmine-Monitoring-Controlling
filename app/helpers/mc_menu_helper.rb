module McMenuHelper
  def activeit?(controller)
    if controller == params[:controller]
     "active"
    end
  end
end