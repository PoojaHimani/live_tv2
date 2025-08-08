# Live TV App

A Flutter application that simulates a digital TV guide interface with program scheduling and video playback capabilities.

## Features

### 🎬 Main Interface
- **Digital TV Guide**: Modern interface matching the design with dark teal background
- **Real-time Clock**: Current time and date display with live updates
- **Time Indicator**: Green lightning bolt indicator showing current time position
- **Channel Categories**: Filter channels by ALL CHANNELS, MY CHANNELS, RECENT, SPORTS, NEWS, MOVIES, KIDS

### 📺 Channel Management
- **CRUD Operations**: Create, Read, Update, Delete channels with categories
- **Channel Logos**: Visual representation of channels
- **Category Filtering**: Organize channels by different categories

### 🎥 Program Management
- **CRUD Operations**: Create, Read, Update, Delete programs
- **Calendar Widget**: Interactive calendar for selecting program start dates and times
- **Scheduling**: Set start date/time and duration for programs with visual calendar interface
- **Video Sources**: Support for YouTube URLs and MP4 files
- **Default Programs**: Set default content for unscheduled time slots
- **Live Status**: Shows "X MIN LEFT" for currently playing programs
- **NEW Tags**: Highlight new content with red badges

### 🔐 Password Protected Settings
- **Secure Access**: Password-protected settings page (default: 1234)
- **Channel Management**: Add, edit, delete channels
- **Program Management**: Add, edit, delete programs
- **Default Program**: Set default content for empty time slots
- **Password Management**: Change settings password

### 🎮 Video Playback
- **YouTube Integration**: Play YouTube videos within the app
- **MP4 Support**: Play local MP4 files
- **No Controls**: Video plays without pause/control options as requested
- **Fullscreen Support**: Toggle fullscreen mode
- **Auto-play**: Videos start automatically when selected

### 🎨 Design Features
- **Dark Theme**: Dark teal color scheme matching the reference design
- **Responsive Layout**: Adapts to different screen sizes
- **Modern UI**: Clean, professional interface
- **Visual Indicators**: Current time line, program highlights, NEW badges

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd live_tv
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Main Interface
- **Navigation**: Use the left sidebar to filter channels by category
- **Program Selection**: Click on any program to start video playback
- **Settings**: Click the settings icon to access password-protected settings

### Settings (Password: 1234)
1. **Channels Tab**: Manage TV channels
   - Add new channels with name, category, and logo
   - Edit existing channels
   - Delete channels

2. **Programs Tab**: Manage TV programs
   - Add programs with title, channel, timing, and video source
   - Use interactive calendar widget to select start date and time
   - Choose between YouTube URL or MP4 file
   - Set duration and scheduling with visual feedback

3. **Default Program Tab**: Set default content
   - Configure what plays during unscheduled time slots

4. **Password Tab**: Change settings password
   - Update the password for settings access

### Video Playback
- **YouTube Videos**: Enter YouTube URLs in program settings
- **MP4 Files**: Select local MP4 files for playback
- **No Controls**: Videos play without pause/stop options
- **Auto-exit**: Returns to guide when video ends

## Technical Details

### Dependencies
- `video_player`: For MP4 file playback
- `youtube_player_flutter`: For YouTube video integration
- `file_picker`: For selecting MP4 files
- `shared_preferences`: For data persistence
- `provider`: For state management
- `intl`: For date/time formatting
- `table_calendar`: For interactive calendar widget

### Architecture
- **State Management**: Provider pattern for app state
- **Models**: Channel and Program data models
- **Widgets**: Modular widget structure
- **Persistence**: SharedPreferences for data storage

### File Structure
```
lib/
├── main.dart              # App entry point
├── home.dart              # Main TV guide interface
├── models/
│   ├── app_state.dart     # Application state management
│   ├── channel.dart       # Channel data model
│   └── program.dart       # Program data model
└── widgets/
    ├── video_player_screen.dart  # Video playback
    ├── settings_screen.dart      # Settings interface
    └── calendar_widget.dart      # Calendar widget for scheduling
```

## Customization

### Adding Sample Data
The app includes sample channels and programs that match the reference design:
- TBS, FOX SPORTS WEST, Food Network, CBS, CNBC
- Sample programs like Seinfeld, sports events, news shows

### Styling
- Colors: Dark teal theme (#1A2F38)
- Accent colors: Green (#4CAF50), Blue (#2196F3)
- Typography: Clean, readable fonts

## Troubleshooting

### Common Issues
1. **Video not playing**: Check internet connection for YouTube videos
2. **MP4 not loading**: Ensure file path is correct and file exists
3. **Settings access**: Default password is "1234"
4. **Dependencies**: Run `flutter pub get` if dependencies are missing

### Platform Support
- Android: Full support
- iOS: Full support (may require additional permissions for file access)
- Web: Limited support (file picker may not work)

## License

This project is created for educational and demonstration purposes.
