module UserAuthorization
  extend ActiveSupport::Concern

  included do
  	before_action :authorize_user
    before_action :load_data, only: [:index, :show, :edit, :update, :destroy, :assign_developer]
  end

  def authorize_user
  	not_authorized = current_user.is_developer? && (controller_name != "todos" || (controller_name == "todos" && action_name != "edit" && action_name != "update"))

  	if not_authorized
  		redirect_to(root_url, alert: "You are not authorized to access that url")
  	end
  end
end