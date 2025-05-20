# Flutter Employee Management App

A Flutter application demonstrating CRUD operations using Back4App as the backend.

# Assignment document
[MyCrossPlatformAssignment.pdf](https://drive.google.com/file/d/1ty8edBCyOsAl5mTSeUMUva7pgEStgZs6/view?usp=drive_link)

# Demo recording
https://youtu.be/RZABm8SFpk4

## Features

1. **Authentication**
   - User signup and login using Back4App's Parse SDK
   - Session management handled by Parse SDK
   - Auto-logout on session expiration

2. **Task Management**
   - Create, Read, Update, Delete (CRUD) operations
   - List view with created task details
   - Form validation for title
   - **(Note: Confirmation dialogs for delete operations are not implemented)**

3. **Notes Management**
   - Create, Read, Update, Delete (CRUD) operations
   - List view with created Notes



## Development Steps

1. Create a new Flutter project:
```bash
flutter create cdp_project
cd cdp_project
```

2. Add required dependencies in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  parse_server_sdk_flutter: ^9.0.0
  flutter_secure_storage: ^9.2.4
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8

```

3. Install dependencies:
```bash
flutter pub get
```

4. Back4App Setup:
   - Create an account on [Back4App](https://www.back4app.com/)
   - Create a new app
   - Get Application ID and Client Key from Security & Keys
   - Create "Task" class with columns:
     - `title` (String)
     - `description` (String)
     - `isDone` (boolean)
   - Create "Note" class with columns:
     - `title` (String)
     - `Content`(String)
     - `Category`(String)
   - Create "User" class (automatically created by Back4App)
     - `username` (String)
     - `password` (String)
     - `email` (String)

5. Configure Back4App credentials:
   Create `lib/back4app_config.dart`:
```dart
class Back4AppConfig {
  static const String applicationId = 'Quux7KtEBWzReYSb091C9HPuET9hmMM96wWaarNshM';
  static const String clientKey = 'ynLZ4mzRiSt7duOaRfWaZAioDB2pcEWPaaeQ0PTobs';
  static const String serverUrl = 'https://parseapi.back4app.com';
  static const String liveQueryUrl = 'wss://cdp_project.b4a.io';
}
```

## Project Structure

### Directory Organization

```
lib/
├── back4app_config.dart        # Back4App credentials and configuration
├── models/
│   ├── note.dart           # Notes data model
│   └── task.dart           # Task data model
├── utils/
│   └── constants.dart         # Custom Style handling
├── screens/
│   ├── home_screen.dart      # Home Screen
│   ├── login_screen.dart     # Login Screen
│   └── signup_screen.dart    # SignUp Screen     
├── widgets/
│   └── custom_widgets.dart   # Widgets
└── main.dart                   # Application entry point

```

### Data Models

1. **Note Model**
```dart
class Note {
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Constructor and methods
}
```

2. **Task Model**
```dart
class Task {
  final String message;
  final String description;
  final bool isDone;
  
  // Constructor and methods
}
```


---

## Testing

1. **Unit Tests**
   - **(Note: Unit tests are not implemented in the codebase)**

2. **Widget Tests**
   - **(Note: Widget tests are not implemented in the codebase)**

3. **Integration Tests**
   - **(Note: Integration tests are not implemented in the codebase)**

---

## Contributing

1. Fork the repository.
2. Create your feature branch.
3. Commit your changes.
4. Push to the branch.
5. Create a Pull Request.

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Authentication Implementation

Authentication is handled entirely through Back4App's Parse Server SDK:

1. **User Authentication**
```dart
// lib/screens/login_screen.dart
Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final user = ParseUser(username, password, null);
      final response = await user.login();

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.username}!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error!.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to login: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

```

2. **SignUp Management**
```dart
// lib/screens/SignUp_screen.dart
Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final user = ParseUser.createUser(username, password, email);
      final response = await user.signUp();

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error!.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
```

3. **Logout Handling**
```dart
// lib/screens/home_screen.dart
Future<void> _logout() async {
    if (_currentUser == null) return;

    try {
      final response = await _currentUser!.logout();
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      } else {
        _showErrorSnackBar(response.error!.message);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to logout: ${e.toString()}');
    }
  }
```

### Security Features

The application leverages Back4App's built-in security features through Parse SDK:

1. **Password Security**
   - Passwords are securely handled by Parse SDK
   - No local password storage or manipulation
   - Secure transmission over HTTPS

2. **Session Management**
   - Automatic session token generation and validation
   - Server-side session expiration
   - Secure token storage
   - Auto-logout on invalid sessions

3. **Error Handling**
```dart
// lib/screens/login_screen.dart
if (response.error != null) {
  switch (response.error!.code) {
    case 101: // Invalid username/password
      errorMessage = 'Invalid email or password';
      break;
    case 205: // Email not verified
      errorMessage = 'Please verify your email first';
      break;
    case -1: // Network error
      errorMessage = 'Network error. Please check your connection';
      break;
    default:
      errorMessage = response.error!.message ?? 'Login failed';
  }
}
```

### Parse SDK Integration

The Parse SDK is initialized in the application's entry point:

```dart
// lib/main.dart
 // Initialize Parse
  await Parse().initialize(
    Back4AppConfig.applicationId,
    Back4AppConfig.serverUrl,
    clientKey: Back4AppConfig.clientKey,
    debug: true, // Set to false in production
    liveQueryUrl: Back4AppConfig.liveQueryUrl,
  );
```

Configuration is managed through:
```dart
// lib/back4app_config.dart
class Back4AppConfig {
  static const String applicationId = 'Quux7KtEBWzReYSb091C9HPuET9hmMM96wWrNshM';
  static const String clientKey = 'ynLZ4mzRiSt7duOaRfWaZAioDB2pcEWPeQ0PTobs';
  static const String serverUrl = 'https://parseapi.back4app.com';
  static const String liveQueryUrl = 'wss://cdp_project.b4a.io';
}
```

## Screens and Features

### 1. Authentication Screens

#### Login Screen (`lib/screens/login_screen.dart`)
- Email and password authentication
- Form validation:
```dart
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  // App Name
                  Text(
                    'TaskyNote',
                    style: AppStyles.heading1.copyWith(
                      fontSize: 32,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Login to your account',
                    style: AppStyles.caption.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username
                        TextFormField(
                          controller: _usernameController,
                          decoration: AppStyles.textFieldDecoration.copyWith(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: AppStyles.textFieldDecoration.copyWith(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          height: 50,
                          child: LoadingButton(
                            isLoading: _isLoading,
                            text: 'Login',
                            onPressed: _login,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sign Up Button
                        SizedBox(
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                            child: Text(
                              'Don\'t have an account? Sign up',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
```
- Loading state handling during authentication
- Error message display
- Navigation to signup screen
- Successful login redirects to Task List Screen

#### Signup Screen (`lib/screens/signup_screen.dart`)
- User registration form
- Form validation for:
  - Email format
  - Password requirements
- Success/Error notifications
```dart
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Create Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 64,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 16),

                Text(
                  'Join TaskyNote',
                  style: AppStyles.heading2,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Create your account to get started',
                  style: AppStyles.caption,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: AppStyles.textFieldDecoration.copyWith(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: AppStyles.textFieldDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: AppStyles.textFieldDecoration.copyWith(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: AppStyles.textFieldDecoration.copyWith(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signup(),
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                SizedBox(
                  height: 50,
                  child: LoadingButton(
                    isLoading: _isLoading,
                    text: 'Sign Up',
                    onPressed: _signup,
                  ),
                ),

                const SizedBox(height: 16),

                // Login Link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
```


#### Task Form Screen (`lib/screens/home_screen.dart`)
- Add/Edit task details
- Form validation for:
  - title (required)
  - description 



## Service Layer

### Authentication Service
- Handles user authentication through Parse SDK
- Session management
- Login/Signup operations
- Error handling

### Task/Notes Service
- CRUD operations for tasks and notes
- Data validation
- Error handling
- Back4App integration


## Error Handling

### Form Validation
- Required field validation
- Email format validation
- Numeric field validation
- Custom error messages

### API Error Handling
- Network error detection
- Parse SDK error handling
- User-friendly error messages
- Session expiration handling

## UI Components

### Common Widgets
- Loading indicators
- Error dialogs
- Form fields with validation
- Notification badges


