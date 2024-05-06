xplore_eats/
├── android/
├── ios/
├── lib/
│   ├── models/
│   │   ├── user.dart                    # Model for user profiles
│   │   ├── food_post.dart               # Model for food posts
│   │   └── preference.dart              # Model for user preferences
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart           # Screen for user login
│   │   │   └── signup_screen.dart          # Screen for user signup
│   │   ├── profile/
│   │   │   ├── profile_screen.dart         # Screen for user profile
│   │   │   └── edit_profile_screen.dart    # Screen for editing user profile
│   │   ├── home_screen.dart                # Home screen displaying food posts
│   │   ├── post_details_screen.dart        # Screen for displaying details of a food post
│   │   └── search_screen.dart              # Screen for searching dishes, restaurants, locations
│   ├── widgets/
│   │   ├── food_post_item.dart             # Widget for displaying a single food post in the feed
│   │   ├── like_button.dart                # Widget for like button on food posts
│   │   └── save_button.dart                # Widget for save button on food posts
│   ├── services/
│   │   ├── authentication_service.dart     # Service for user authentication (Firebase Auth)
│   │   ├── database_service.dart           # Service for interacting with Firestore (database operations)
│   │   └── storage_service.dart            # Service for interacting with Firebase Storage
│   ├── utils/
│   │   └── constants.dart                  # File for storing constant values used throughout the app
│   └── main.dart
├── test/
├── assets/
│   ├── images/                             # Directory for storing images
│   └── fonts/                              # Directory for storing fonts
├── pubspec.yaml
└── README.md
