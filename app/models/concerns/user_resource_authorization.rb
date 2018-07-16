module UserResourceAuthorization
  extend ActiveSupport::Concern

  included do
    validate :can_user_manage_resource?, on: :create
  end

  def can_user_manage_resource?
  	errors.add(:user, "not authorized to manage #{self.class.name}s") if ["Project", "Todo", "AssignedProject"].include?(self.class.name) && user.role == User::ROLES[:dev]
  end
end