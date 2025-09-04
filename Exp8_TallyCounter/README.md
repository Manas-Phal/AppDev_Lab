# Experiment 8: Android Studio Setup + Counter App (Kotlin Version)

## Aim
To set up the Android Studio development environment and create a Kotlin-based counter application demonstrating the use of Android UI components, event handling, state persistence, and dynamic styling.

##  Part 1: Android Studio Setup + Basic Counter App
# Environment Setup
Installed Android Studio from developer.android.com
Created a new Android project using the Empty Views Activity template
Configured Kotlin as the project language
Set up an Android Virtual Device (AVD) for emulator testing
Project configuration:
Project Name: CounterApp
Package: com.example.tallycounter
Language: Kotlin
Minimum SDK: API 28 (Android 9.0)
Compile SDK: API 36
Gradle Plugin Version: 8.9.1

### Steps Followed

1.✅ Project Initialization
  Created project with Kotlin support
  Waited for Gradle to sync and resolved all dependencies
  Installed API 36 (Android 14) via SDK Manager
  ✅ UI Design (activity_main.xml)
  Used a vertical LinearLayout for base layout
  Added a TextView to display the counter value
  Added three buttons: Increment (+), Decrement (-), Reset
  Aligned and spaced buttons using a horizontal LinearLayout
  Applied color-coded button styles and large font sizes
  Added margin, padding, and background styling

2. ✅ Logic Implementation (MainActivity.kt)
Connected UI elements via findViewById()
Declared counter as an integer variable
Implemented click listeners for:
Increment Button: Adds 1
Decrement Button: Subtracts 1
Reset Button: Sets counter to 0
Displayed Toast messages for each action
Used setTextColor() to update counter color dynamically
Used onSaveInstanceState() and onRestoreInstanceState() to preserve state on rotation


## 🌟 Part 2: Extended Counter App (State, UI, UX)
🚀 Additional Features Implemented
🔘 Buttons
Button	Action	Color
➕ Increment	Increases counter by 1	Green
➖ Decrement	Decreases counter by 1	Red
🔄 Reset	Resets counter to 0	Orange
🎨 Enhanced UI Design
Counter display with large 64sp bold text
Color changes based on value:
Green for positive
Red for negative
Blue for zero
Clean, minimal layout with:
Rounded buttons
Proper spacing and elevation
Light grey background
Emojis in toast messages for better user feedback

# 🔁 State Management
onSaveInstanceState() stores counter value before configuration changes
onRestoreInstanceState() restores value after screen rotation or activity recreation
Ensures counter value is persistent and user-friendly

📊 Expected Output
![Counter App ](![WhatsApp Image 2025-09-04 at 12 12 45_dd283827](https://github.com/user-attachments/assets/5c7fa71e-9528-4ccc-802c-0b64f1a34d8b))
![Counter App ](![c1](https://github.com/user-attachments/assets/46ad8028-906b-423b-8464-6de804ff5d12))
![Counter App ](![WhatsApp Image 2025-09-04 at 12 14 00_9d3c96be](https://github.com/user-attachments/assets/93029c0c-c099-4429-a0e9-276bebae4054))

Action	Result
App Launch	Shows 0 in blue
Tap + Button	Counter increases by 1, turns green
Tap - Button	Counter decreases by 1, turns red
Tap Reset Button	Counter resets to 0, turns blue
Rotate Screen	Counter value stays the same
Toast Message	Shows action-specific notification

### ✅ Summary of Implemented Concepts
Android Studio setup with Kotlin
UI creation using XML layouts
Event handling with Kotlin click listeners
State persistence using onSaveInstanceState()
Dynamic UI updates using TextView.setTextColor()
Toast messages for user feedback


# 🧾 Final Notes
The app is responsive and handles user interactions gracefully
State persistence ensures a better user experience
The project structure follows good development practices
Modern UI principles were applied for clarity and usability
