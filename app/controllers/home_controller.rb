class HomeController < ApplicationController
  def index
  	@data = current_user.dashboard_data(params[:view_type])
  end
end
