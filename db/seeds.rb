# Clear existing data
puts "Clearing existing data..."
ActivityLog.destroy_all
Comment.destroy_all
Task.destroy_all
ProjectMembership.destroy_all
Project.destroy_all
User.destroy_all

puts "Creating users..."
admin = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin'
)

john = User.create!(
  email: 'john@example.com',
  password: 'password123',
  first_name: 'John',
  last_name: 'Doe',
  role: 'member'
)

jane = User.create!(
  email: 'jane@example.com',
  password: 'password123',
  first_name: 'Jane',
  last_name: 'Smith',
  role: 'member'
)

puts "Creating projects..."
project1 = Project.create!(
  name: 'TaskCollab Platform',
  description: 'Building a collaborative task management system',
  owner: admin,
  status: 'active'
)

project2 = Project.create!(
  name: 'Mobile App Development',
  description: 'iOS and Android mobile application',
  owner: john,
  status: 'active'
)

puts "Adding project members..."
ProjectMembership.create!(
  project: project1,
  user: john,
  role: 'manager'
)

ProjectMembership.create!(
  project: project1,
  user: jane,
  role: 'member'
)

ProjectMembership.create!(
  project: project2,
  user: admin,
  role: 'member'
)

puts "Creating tasks..."
Task.create!(
  project: project1,
  creator: admin,
  assignee: john,
  title: 'Setup authentication system',
  description: 'Implement JWT-based authentication',
  status: 'done',
  priority: 'high',
  due_date: 1.week.from_now
)

Task.create!(
  project: project1,
  creator: admin,
  assignee: jane,
  title: 'Design project dashboard',
  description: 'Create mockups for the main dashboard',
  status: 'in_progress',
  priority: 'medium',
  due_date: 3.days.from_now
)

Task.create!(
  project: project1,
  creator: john,
  assignee: john,
  title: 'Write API documentation',
  description: 'Document all API endpoints with examples',
  status: 'todo',
  priority: 'low',
  due_date: 1.week.from_now
)

Task.create!(
  project: project2,
  creator: john,
  assignee: admin,
  title: 'Setup React Native project',
  description: 'Initialize the mobile app project structure',
  status: 'in_progress',
  priority: 'high',
  due_date: 2.days.from_now
)

puts "Creating comments..."
task = Task.first
Comment.create!(
  task: task,
  user: john,
  content: 'Great work on the authentication! Works perfectly.'
)

Comment.create!(
  task: task,
  user: admin,
  content: 'Thanks! Let me know if you find any issues.'
)

puts "\n" + "="*60
puts "Seed data created successfully!"
puts "="*60
puts "\nTest Accounts:"
puts "  Admin: admin@example.com / password123"
puts "  John:  john@example.com / password123"
puts "  Jane:  jane@example.com / password123"
puts "\nProjects: #{Project.count}"
puts "Tasks: #{Task.count}"
puts "Comments: #{Comment.count}"
puts "="*60
