puts "------------------ SEEDING DUMMY DATA IN DB ------------------"

password = "12345678"
managers = []
developers = []
projects = []
todos = []

#Create managers
for i in 1..3 do
	manager = User.new
	manager.name = "Manager #{i}"
	manager.email = "mgr#{i}@abc.com"
	manager.password = password
	manager.password_confirmation = password
	manager.role = User::ROLES[:mgr]
	manager.save

	managers << manager
end

#Create developers
for i in 1..10 do
	developer = User.new
	developer.name = "Developer #{i}"
	developer.email = "dev#{i}@abc.com"
	developer.password = password
	developer.password_confirmation = password
	developer.role = User::ROLES[:dev]
	developer.save

	developers << developer
end

#Create projects
managers.each{|manager|
	for i in 1..5 do
		projects << manager.projects.create(name: "Project_#{manager.id}_#{i}")
	end
}

#Create todos
projects.each{|project|
	for i in 1..10 do
		todos << project.todos.create(name: "Todo_#{project.id}_#{i}")
	end
}

puts "------------------ FINISHED SEEDING ------------------"