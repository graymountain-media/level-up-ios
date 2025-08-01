# Level Up Fitness Authentication Flow

This document outlines the authentication flow implemented in the Level Up Fitness app, including signup, email confirmation, login, and onboarding processes.

## Overview

The authentication flow follows these steps:

1. **Signup**: User provides email and password
2. **Email Confirmation**: User confirms their email via a link sent to their inbox
3. **Login**: User signs in with confirmed credentials
4. **Onboarding**: First-time users complete their profile with personal details
5. **Main App**: User accesses the full application features

## Components

### 1. UserDataService

The central service managing authentication state and API calls:

- **State Management**:
  - `isAuthenticated`: Tracks if user is logged in
  - `isLoadingSession`: Tracks session loading state
  - `hasCompletedOnboarding`: Tracks if user has completed profile setup
  - `currentUser`: Stores the current authenticated user

- **Key Methods**:
  - `signUp(email:password:)`: Registers new user with Supabase
  - `signIn(email:password:)`: Authenticates existing user
  - `signOut()`: Ends user session
  - `checkOnboardingStatus()`: Verifies if user has completed profile setup
  - `updateProfile(firstName:lastName:avatarName:)`: Saves user profile data

### 2. LoginView

Handles user registration and authentication:

- **Features**:
  - Toggle between login and signup modes
  - Simplified signup form (email and password only)
  - Form validation
  - Navigation to email confirmation screen
  - Error handling with alerts

### 3. ConfirmEmailView

Guides users through the email confirmation process:

- **Features**:
  - Instructions to check email
  - Button to open Mail app
  - Returns to login screen after confirmation

### 4. OnboardingView

Collects additional user information after first login:

- **Features**:
  - Form for first name, last name, and avatar name
  - Validation of required fields
  - Saves profile data to Supabase
  - Transitions to main app after completion

### 5. RootView

Manages navigation based on authentication state:

- **Logic**:
  - Shows loading screen while checking session
  - Shows login screen for unauthenticated users
  - Shows onboarding for authenticated users without complete profiles
  - Shows main app for fully authenticated and onboarded users
  - Handles deeplinks for email confirmation

## User Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │
│   Signup    │────▶│    Email    │────▶│    Login    │
│             │     │ Confirmation│     │             │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │
│  Main App   │◀────│ Onboarding  │◀────│   Session   │
│             │     │  (if needed)│     │  Validation │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Deeplink Handling

The app handles deeplinks for email confirmation:

- **Format**: `level-up-fitness://login-callback?[params]`
- **Processing**: When detected, shows confirmation alert
- **User Experience**: User is informed their email is confirmed and can proceed to login

## Database Integration

The app interacts with these Supabase tables:

- **auth.users**: Managed by Supabase Auth
- **public.profiles**: Contains user profile information
  - Fields: `id`, `first_name`, `last_name`, `avatar_name`, `updated_at`

## Error Handling

- Form validation errors shown as alerts
- Authentication errors shown as alerts
- Database errors logged and handled gracefully

## Future Improvements

- Password reset functionality
- Social authentication options
- Remember me functionality
- Biometric authentication
- Enhanced security measures
