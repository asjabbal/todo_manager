class Todo < ApplicationRecord
	NEW = "unstarted".freeze
	IN_PROGRESS = "started".freeze
	DONE = "completed".freeze
	STATUS = [NEW, IN_PROGRESS, DONE].freeze

	enum status: STATUS
  belongs_to :project

  scope :assigned, -> { where.not(developer_id: nil) }
  scope :unassigned, -> { where(developer_id: nil) }

	include UserResourceAuthorization

  validates :name, presence: true

  def user
  	project.user
  end

  def assigned_dev
  	User.find(developer_id)
  end

  def assigned?
  	developer_id.present?
  end
end

Todo::STATUS_TEXT = {
	Todo::NEW => "New",
	Todo::IN_PROGRESS => "In Progress",
	Todo::DONE => "Done"
}