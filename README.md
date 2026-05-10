# B-Fed - Baby Formula Feeding Tracker

A beautiful and intuitive iOS app for tracking baby formula feeds. Built with SwiftUI and SwiftData.

## Features

### Core Features
- **Log Feeds**: Quickly log each feeding session with amount, time, and notes
- **Automatic Time Tracking**: App automatically records feed times
- **Timer Mode**: Start a timer to track feeding duration in real-time
- **Feed Counter**: Track number of feeds per day automatically
- **Amount Tracking**: Record amount taken per feed with support for ml and oz
- **Statistics**: View averages, totals, and trends

### Dashboard
- Live timer for active feeds with animated "LIVE" indicator
- Today's summary with key metrics (total feeds, total amount, average, duration)
- Time since last feed display
- Last 24 hours summary
- Quick action buttons for fast logging

### Feed History
- Chronological list of all feeds grouped by day
- Visual timeline with start/end times
- Quick-edit functionality
- Swipe-to-delete
- Duration and notes indicators

### Statistics & Analytics
- Multiple time periods: Today, Last 7 Days, Last 30 Days, All Time
- Summary cards with key metrics
- Interactive charts showing daily amounts and feed counts
- Detailed statistics including largest/smallest feeds and total duration

## Technical Details

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Architecture
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Architecture Pattern**: MVVM with Observable macro
- **Charts**: Swift Charts (iOS 17+)

### Project Structure
```
B-Fed/
├── B_FedApp.swift              # App entry point
├── ContentView.swift           # Main tab view
├── Models/
│   └── Feed.swift              # Feed model and statistics
├── ViewModels/
│   └── FeedStore.swift         # Data operations and business logic
├── Views/
│   ├── DashboardView.swift     # Main dashboard
│   ├── LogFeedView.swift       # Add new feed
│   ├── FeedHistoryView.swift   # Feed list and edit
│   └── StatisticsView.swift    # Analytics and charts
├── Resources/
│   └── Assets.xcassets/        # App icons and assets
└── Info.plist
```

## How to Build and Run

### Option 1: Using Xcode

1. Open Xcode 15.0 or later
2. Select "File" → "Open" and navigate to the `B-Fed` folder
3. Wait for Swift Package Manager to resolve dependencies
4. Select your target device or simulator (iOS 17.0+)
5. Press `Cmd+R` to build and run

### Option 2: Command Line

```bash
# Navigate to project directory
cd B-Fed

# Build the project (requires Xcode command line tools)
xcodebuild -scheme B-Fed -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Creating an Xcode Project

Since this is a Swift Package Manager project, you can also create an Xcode project:

1. Create a new iOS App project in Xcode
2. Copy all Swift files from the `B-Fed` folder into your project
3. Ensure "SwiftData" is imported in your project settings
4. Build and run

## Usage

### Logging a Feed

1. Tap the "+" button on the Dashboard or History tab
2. Enter the amount (or use quick-select buttons)
3. Choose the unit (ml or oz)
4. Set the time (defaults to now)
5. Add optional duration and notes
6. Tap "Save Feed"

### Using the Timer

1. In the Log Feed screen, toggle "Start Timer"
2. Tap "Start Feeding" to begin
3. The active feed card appears on the Dashboard
4. Tap "End Feeding" when finished

### Viewing Statistics

1. Navigate to the "Stats" tab
2. Select a time period (Today, Last 7 Days, etc.)
3. View summary cards and charts
4. Scroll down for detailed statistics

### Editing a Feed

1. Go to the "History" tab
2. Tap on any feed or swipe left and tap "Edit"
3. Modify the details
4. Tap "Save Changes"

## Data Model

### Feed
- `id`: Unique identifier
- `startTime`: When the feed began
- `endTime`: When the feed ended (optional)
- `amount`: Amount consumed
- `unit`: Unit of measurement (ml/oz)
- `notes`: Optional notes
- `createdAt`: Record creation timestamp

## Future Enhancements

- [ ] Multiple baby profiles
- [ ] Growth tracking integration
- [ ] Export data to CSV/PDF
- [ ] Siri Shortcuts support
- [ ] Widgets for home screen
- [ ] iCloud sync
- [ ] Dark mode support
- [ ] Customizable feeding reminders

## License

This project is available for personal and commercial use.

## Credits

Built with ❤️ using SwiftUI and SwiftData.
