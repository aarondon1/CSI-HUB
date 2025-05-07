# Dolphin Finder

A Flutter application for connecting developers and finding project collaborators.

## Features

- User authentication (Email and Google Sign-in)
- Profile management with customizable avatars
- Project creation and management
- Real-time notifications
- Like and join request system
- Social media integration (GitHub, Instagram)

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Supabase account
- Firebase account (for notifications)
- iOS/Android development environment setup

## Getting Started

1. **Clone the repository**
   ```bash
   git clone dolphin-finder.git
   cd dolphin-finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**

   Create a `.env` file in the root directory with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_URL2=your_supabase_url
   ```

   You can obtain these values from your Supabase project settings.

4. **Firebase Setup**

   - Create a new Firebase project
   - Add iOS and Android apps to your Firebase project
   - Download and add the configuration files:
     - iOS: `GoogleService-Info.plist` to `ios/Runner/`
     - Android: `google-services.json` to `android/app/`

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── screens/          # UI screens
├── widgets/          # Reusable widgets
├── supabase/         # Supabase client configuration
└── assets/          # Images and other static assets
```

## Dependencies

- `supabase_flutter`: For backend and authentication
- `flutter_dotenv`: For environment variable management
- `image_picker`: For profile picture uploads
- `intl`: For date formatting
- `icons_plus`: For additional icons

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Security

- All sensitive information is stored in environment variables
- API keys and configuration files are not committed to the repository
- User authentication is handled through Supabase
- File uploads are validated for type and size

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email [wilkenslafortune@Gmail.com] or open an issue in the repository.
