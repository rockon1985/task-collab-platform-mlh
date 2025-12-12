#!/bin/bash

echo "Restarting Rails backend..."
pkill -f "rails s" 2>/dev/null
sleep 1
cd /home/rails/rails_work/task-collab-platform
rails s -p 3000 -b 0.0.0.0 &

echo "Rails server restarted on port 3000"
echo ""
echo "Frontend is running on: http://localhost:3001"
echo "Backend is running on: http://localhost:3000"
echo ""
echo "Test user credentials:"
echo "Email: admin@example.com"
echo "Password: password"
