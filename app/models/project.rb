class Project < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy
  has_many :developers, class_name: "AssignedProject", dependent: :destroy

  include UserResourceAuthorization

  validates :name, presence: true

  def assigned_devs
  	User.where("id IN(?)", developers.pluck(:developer_id))
  end

  def unassigned_devs
  	assigned_devs.count > 0 ? User.developers.where("id NOT IN(?)", assigned_devs.pluck(:id)) : User.developers
  end

  def assigned_todos
  	todos.assigned
  end

  def unassigned_todos
  	todos.unassigned
  end
end
