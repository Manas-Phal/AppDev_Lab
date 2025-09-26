# React Native Task Manager with Firebase Firestore

A **React Native** app integrated with **Firebase Firestore** that implements full **CRUD operations** for a task management system. The app supports **real-time updates**, **offline mode**, **search functionality**, **status tracking**, and **timestamps**.

---

## Features

- **Firestore Integration:** Google Cloud Firestore (NoSQL) with real-time sync and offline support.
- **Data Structure:**  
  - **Tasks Collection Fields:**  
- `title` (string)  
- `description` (string)  
- `status` (string: "pending" or "done")  
- `createdAt` (timestamp)

- **CRUD Operations:**  
1. **Create:** Add a new task.  
2. **Read:** Retrieve and display tasks with real-time updates.  
3. **Update:** Modify task details or status.  
4. **Delete:** Remove a task.  

- **UI Components:**  
- **Add Task:** Form to input task details and save to Firestore.  
- **Task List:** Display all tasks with live updates.  
- **Update Task:** Edit task details or status.  
- **Delete Task:** Remove a task with a single click.  
- **Status Toggle:** Mark tasks as "pending" or "done".  
- **Search:** Filter tasks by title.  

- **Additional Features:**  
- **Timestamps:** Track creation date for each task.  
- **Offline Support:** Work without an internet connection.  
- **Multi-device Sync:** Real-time updates across devices.  

---

## Setup Instructions

1. **Create Firebase Project:**  
 - Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.  
 - Enable **Cloud Firestore**.  

2. **Configure Android App:**  
 - Download `google-services.json` from Firebase.  
 - Add it to the `android/app` folder of your React Native project.  

3. **Install Dependencies:**  
 ```bash
 npm install @react-native-firebase/app @react-native-firebase/firestore
 npm install firebase

