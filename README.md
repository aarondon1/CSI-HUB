# Dolphin Finder

Dolphin Finder is a Flutter-based mobile application designed to help students and hobbyists connect and collaborate on technology-driven projects. The app uses Supabase for secure user authentication and integrates with a Django REST Framework (DRF) backend to handle dynamic data operations.

## System Architecture

### Frontend (Flutter)
- Built with Flutter for cross-platform mobile development
- Implements Material Design for consistent UI/UX
- Features modular screen architecture with dedicated pages for:
  - Home/Project Discovery
  - Profile Management
  - Project Creation
  - Settings

### Authentication (Supabase)
- Handles user authentication flows (sign in, sign up, logout)
- Manages session tokens and user states
- Provides secure JWT-based authentication

### Backend (Django REST Framework)
- Serves as the central API layer
- Handles core business logic and database operations
- Exposes RESTful endpoints for:
  - Project management
  - Profile operations
  - Join request handling
  - Search and filtering

## Design Patterns

### Frontend Patterns
- **Service Layer Pattern**: Separates API calls and business logic (ApiService, AuthService)
- **Repository Pattern**: Manages data operations and caching
- **Provider Pattern**: Handles state management
- **Factory Pattern**: Creates instances of models and services

### Backend Patterns
- **MVC Architecture**: Separates models, views, and controllers
- **REST Architecture**: Implements RESTful API endpoints
- **Middleware Pattern**: Handles authentication and request processing
- **Repository Pattern**: Manages database operations

## Features

- User authentication and profile management
- Project creation and discovery
- Join request system for project collaboration
- Search and filter functionality
- Real-time updates for project status

## API Endpoints

- `/api/auth/` - Authentication endpoint
- `/create-profile/` - Create a user profile
- `/profile/<user_id>/` - Get or update a profile
- `/me/` - Get current user profile
- `/create-project/` - Create a new project
- `/projects/<pk>/` - Get, update, or delete a project
- `/user-projects/<user_id>/` - Get projects for a specific user
- `/homepage/` - Get all projects (with optional search)
- `/join-request/` - Create a join request
- `/join-request/<pk>/status/` - Update join request status

## Setup

### Backend Setup
1. Clone the repository
2. Create a virtual environment: `python -m venv .venv`
3. Activate the virtual environment:
   - Windows: `.venv\Scripts\activate`
   - macOS/Linux: `source .venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Copy `.env.example` to `.env` and fill in your environment variables
6. Run migrations: `python manage.py migrate`
7. Start the development server: `python manage.py runserver`

### Frontend Setup
1. Navigate to the frontend directory
2. Install Flutter dependencies: `flutter pub get`
3. Configure environment variables in `.env`
4. Run the app: `flutter run`

## Environment Variables

Required environment variables:
- `SUPABASE_JWT_SECRET`
- `SECRET_KEY`
- `host_ID`
- `supabase_password`
- `API_URL`
- `SUPABASE_ANON_KEY`

## Technologies Used

- Flutter for mobile development
- Supabase for authentication
- Django REST Framework for backend API
- PostgreSQL for database
- Material Design for UI components

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
