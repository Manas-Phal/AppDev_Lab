# React Native Task Manager with Firebase Firestore

This is a task management app built with **React Native** and **Firebase Firestore**. It supports full **CRUD operations** (Create, Read, Update, Delete), real-time updates, offline capabilities, status tracking, and search functionality.

---

## Features

- **Firestore Integration**  
  - Real-time synchronization and offline support using Firebase Firestore (NoSQL).
  
- **Task Management**  
  - Create, read, update, and delete tasks.
  - Tasks have fields such as:
    - `title` (string)
    - `description` (string)
    - `status` (string: "pending" or "done")
    - `createdAt` (timestamp)

- **UI Components**  
  - **Add Task**: Form to input task details and save to Firestore.  
  - **Task List**: Display all tasks with real-time updates.  
  - **Update Task**: Edit task details or status.  
  - **Delete Task**: Remove a task with a single click.  
  - **Status Toggle**: Mark tasks as "pending" or "done".  
  - **Search**: Filter tasks by title.

- **Additional Features**  
  - **Timestamps**: Automatically track creation date for each task.  
  - **Offline Support**: Continue working without an internet connection.  
  - **Multi-device Sync**: Real-time updates are reflected across all devices.

---

## Screenshots

![App Screenshot]![WhatsApp Image 2025-09-01 at 16 33 54_73c91fef](https://github.com/user-attachments/assets/280b986d-d6b8-4654-8e3e-91c16072ae21)
![App Screenshot]![WhatsApp Image 2025-09-01 at 16 39 12_b7fbfb46](https://github.com/user-attachments/assets/afa134c0-a263-42c3-a871-629ff9bafa8f)




---

## Setup Instructions

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/) and create a new Firebase project.
- Enable **Cloud Firestore**.

### 2. Configure Android App
- Download the `google-services.json` from Firebase.
- Place the `google-services.json` file in the `android/app` folder of your React Native project.

### 3. Install Dependencies
Run the following command to install required dependencies:

```bash
npm install @react-native-firebase/app @react-native-firebase/firestore


