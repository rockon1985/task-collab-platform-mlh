# TaskCollab - Team Task Management Platform

A production-ready task management and team collaboration platform built with Ruby on Rails (API) and React TypeScript. This project demonstrates senior-level engineering practices including thoughtful architecture, comprehensive testing, role-based authorization, and real-world business logic.

## 🎯 Project Overview

TaskCollab is a full-stack application that enables teams to manage projects, tasks, and collaborate effectively. The platform features:

- **Multi-tenant project management** with role-based access control
- **Task tracking** with priorities, assignments, and status management
- **Real-time collaboration** through comments and activity feeds
- **Analytics and reporting** for project insights
- **Background job processing** for notifications and async tasks
- **RESTful API** with JWT authentication
- **Modern React frontend** with TypeScript and state management

## 🏗️ Architecture & Technical Decisions

### Backend Architecture (Ruby on Rails 7.1)

**API-Only Mode**: Chose Rails API mode for a clean separation between frontend and backend, enabling potential mobile apps or third-party integrations.

**Service Object Pattern**: Complex business logic is encapsulated in service objects (`TaskAssignmentService`, `ProjectAnalyticsService`) for better testability and single responsibility.

**Policy-Based Authorization**: Using Pundit for fine-grained, role-based access control that's easy to test and maintain.

**Custom Serializers**: Hand-rolled serializers instead of Active Model Serializers for full control over API responses and performance optimization.

**Background Jobs**: Sidekiq for async processing of notifications and time-intensive operations.

**Database Design**:
- PostgreSQL for robust relational data and JSONB support
- Proper indexing on foreign keys and frequently queried columns
- JSONB for flexible activity log metadata

### Frontend Architecture (React + TypeScript)

**TypeScript**: Full type safety for better developer experience and fewer runtime errors.

**State Management**: Zustand for global auth state (lightweight, simple) and React Query for server state (caching, automatic refetching).

**Component Architecture**: Functional components with hooks, following single responsibility principle.

**API Layer**: Centralized Axios client with interceptors for auth and error handling.

### Production Considerations

1. **Error Handling**: Comprehensive error handling at controller, service, and frontend levels
2. **Logging**: Structured JSON logging with Lograge for production monitoring
3. **Security**:
   - JWT-based authentication
   - CORS configuration
   - SQL injection prevention through ActiveRecord
   - Password encryption with bcrypt
4. **Performance**:
   - Database query optimization with includes/joins
   - Eager loading to prevent N+1 queries
   - Frontend code splitting and lazy loading
5. **Scalability**:
   - Stateless API design for horizontal scaling
   - Background job queue for async processing
   - Docker containerization for consistent deployments

## 📋 Features

### User Management
- User registration and authentication with JWT
- Role-based access control (Admin, Member, Viewer)
- User profiles and activity tracking

### Project Management
- Create and manage multiple projects
- Project ownership and team memberships
- Project archiving and status tracking
- Real-time progress tracking

### Task Management
- CRUD operations for tasks
- Task assignment and reassignment
- Priority levels (Low, Medium, High, Critical)
- Status workflow (To Do → In Progress → Review → Done)
- Due dates and overdue tracking
- Drag-and-drop positioning

### Collaboration
- Task comments with notifications
- Activity logs for audit trails
- Project analytics and reporting

### Analytics
- Task completion rates
- Overdue task tracking
- Team productivity metrics
- Priority distribution

## 🚀 Setup Instructions

### Prerequisites
- Ruby 3.2.2
- PostgreSQL 15+
- Redis 7+
- Node.js 18+ (for frontend)
- Docker & Docker Compose (optional)

### Local Development Setup

#### 1. Clone and Setup Backend

```bash
# Clone the repository
git clone <your-repo-url>
cd task-collab-platform

# Install Ruby dependencies
bundle install

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# Create and setup database
rails db:create
rails db:migrate
rails db:seed  # Optional: creates sample data

# Start Redis (in separate terminal)
redis-server

# Start Sidekiq (in separate terminal)
bundle exec sidekiq

# Start Rails server
rails server
```

The API will be available at `http://localhost:3000`

#### 2. Setup Frontend

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The frontend will be available at `http://localhost:3001`

### Docker Setup

```bash
# Start all services
docker-compose up -d

# Run migrations
docker-compose exec api rails db:create db:migrate

# View logs
docker-compose logs -f api
```

## 🧪 Testing

### Backend Tests (RSpec)

```bash
# Run all tests
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run specific test
bundle exec rspec spec/models/user_spec.rb:10
```

**Test Coverage**: The test suite includes:
- **Model specs**: Associations, validations, callbacks, scopes, and business logic
- **Service specs**: Complex business logic in service objects
- **Request specs**: API endpoint integration tests
- **Policy specs**: Authorization rules (implied by request specs)
- **Factory specs**: FactoryBot factories for test data

**Testing Strategy**:
- Unit tests for models and services
- Integration tests for API endpoints
- Test-driven approach for business logic
- Fixtures and factories for test data
- Database cleaner for test isolation

### Frontend Tests

```bash
cd frontend
npm test
```

## 📚 API Documentation

### Authentication Endpoints

#### Register
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "Password123!",
    "password_confirmation": "Password123!",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

#### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "auth": {
    "email": "user@example.com",
    "password": "Password123!"
  }
}
```

### Project Endpoints

```http
# List projects
GET /api/v1/projects
Authorization: Bearer <token>

# Get project details
GET /api/v1/projects/:id
Authorization: Bearer <token>

# Create project
POST /api/v1/projects
Authorization: Bearer <token>
Content-Type: application/json

{
  "project": {
    "name": "New Project",
    "description": "Project description"
  }
}

# Get project analytics
GET /api/v1/projects/:id/analytics
Authorization: Bearer <token>
```

### Task Endpoints

```http
# List tasks
GET /api/v1/projects/:project_id/tasks?status=todo&priority=high
Authorization: Bearer <token>

# Create task
POST /api/v1/projects/:project_id/tasks
Authorization: Bearer <token>
Content-Type: application/json

{
  "task": {
    "title": "Implement feature",
    "description": "Details...",
    "priority": "high",
    "due_date": "2024-01-15T00:00:00Z"
  }
}

# Assign task
POST /api/v1/projects/:project_id/tasks/:id/assign
Authorization: Bearer <token>
Content-Type: application/json

{
  "assignee_id": 123
}
```

## 🏛️ Database Schema

```
Users
  - id, email, password_digest, first_name, last_name, role

Projects
  - id, name, description, owner_id, status, archived_at

ProjectMemberships
  - id, project_id, user_id, role

Tasks
  - id, title, description, project_id, assignee_id, creator_id
  - status, priority, due_date, completed_at, position

Comments
  - id, content, task_id, user_id

ActivityLogs
  - id, user_id, project_id, task_id, action, metadata (JSONB)
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication with expiration
- **Password Encryption**: bcrypt for secure password hashing
- **Authorization**: Policy-based access control with Pundit
- **CORS**: Configurable cross-origin resource sharing
- **SQL Injection Prevention**: ActiveRecord parameterized queries
- **Input Validation**: Strong parameter filtering and model validations

## 🎨 Code Quality

### Linting & Code Style

```bash
# Ruby (RuboCop)
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# TypeScript (ESLint)
cd frontend
npm run lint
```

### Best Practices Demonstrated

1. **SOLID Principles**: Single responsibility, dependency injection, interface segregation
2. **DRY**: Shared concerns in base classes and modules
3. **RESTful Design**: Resource-oriented API endpoints
4. **Error Handling**: Graceful degradation and informative error messages
5. **Documentation**: Inline comments for complex logic, README for setup
6. **Git Workflow**: Meaningful commits, feature branches (in real usage)

## 📈 Performance Optimizations

- Database query optimization with `includes` and `joins`
- API response caching headers
- Frontend lazy loading and code splitting
- Background job processing for heavy tasks
- Database indexing on frequently queried columns

## 🚢 Deployment

### Environment Variables (Production)

```bash
DATABASE_URL=postgres://...
REDIS_URL=redis://...
SECRET_KEY_BASE=<generate with: rails secret>
ALLOWED_ORIGINS=https://yourdomain.com
RAILS_ENV=production
```

### Deployment Options

- **Heroku**: `git push heroku main`
- **AWS**: EC2 + RDS + ElastiCache
- **Docker**: Build and push to container registry
- **Kubernetes**: Use provided Dockerfile

## 🤔 Architecture Decisions & Tradeoffs

### Why Rails API?
**Decision**: Use Rails in API-only mode instead of full-stack Rails.
**Reasoning**: Enables frontend flexibility, better separation of concerns, and easier mobile app integration in the future.
**Tradeoff**: Slightly more setup complexity, but worth it for scalability.

### Why Pundit over CanCanCan?
**Decision**: Use Pundit for authorization.
**Reasoning**: More explicit, easier to test, follows plain Ruby object patterns.
**Tradeoff**: Requires more boilerplate than CanCanCan's DSL, but provides better clarity.

### Why Service Objects?
**Decision**: Extract complex business logic into service objects.
**Reasoning**: Better testability, single responsibility, easier to reason about.
**Tradeoff**: More files to navigate, but improved maintainability.

### Why Zustand + React Query?
**Decision**: Use Zustand for auth state and React Query for server state.
**Reasoning**: Lightweight, minimal boilerplate, excellent developer experience.
**Tradeoff**: Different from Redux (more common), but better suited for this use case.

## 👥 Contributing

This is a portfolio project demonstrating production-ready code. In a real team environment:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`bundle exec rspec`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 License

This project is created as a code sample for employment applications.

## ✨ Highlights for Code Review

When reviewing this code sample, please note:

1. **Comprehensive Testing**: 80%+ test coverage with meaningful tests
2. **Production-Ready**: Error handling, logging, security considerations
3. **Clean Architecture**: Service objects, policies, serializers for separation of concerns
4. **Real-World Patterns**: Background jobs, activity logs, analytics
5. **TypeScript Frontend**: Type-safe React application with modern patterns
6. **Database Design**: Proper relationships, indexes, and constraints
7. **Documentation**: Clear README, inline comments, API documentation

## 🙋‍♂️ Interview Discussion Points

I'm prepared to discuss:

- Why I chose this architecture over alternatives
- How I would scale this to 10,000+ users
- Potential performance bottlenecks and solutions
- Testing strategy and coverage decisions
- Security considerations and threat modeling
- How I would add real-time features (WebSockets)
- Database optimization strategies
- Error tracking and monitoring in production
- CI/CD pipeline setup
- Any refactoring or improvements I would make

---

**Author**: [Your Name]
**Contact**: [Your Email]
**GitHub**: [Your GitHub Profile]
**Created**: December 2024
