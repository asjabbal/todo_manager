class AssignedProject < ApplicationRecord
  belongs_to :project
  belongs_to :developer, class_name: "User"

  include UserResourceAuthorization

  def user
  	project.user
  end
end
