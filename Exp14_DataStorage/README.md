# Experiment 14: Data Storage and Databases with SQLite

## Aim
Implement local data storage using SQLite in mobile applications. Extend previously developed apps (Calculator and To-Do List) by replacing in-memory storage with persistent database operations. Additionally, demonstrate a basic **Student Registration Form** with CRUD functionality.

## Overview
This experiment introduces **SQLite** for local data persistence in mobile apps. Unlike in-memory storage where data is lost upon app closure, SQLite allows data to survive app restarts and device reboots.  

Applications developed in this experiment:  
1. Calculator with history storage  
2. To-Do List with persistent tasks  
3. Student Registration Form  

## Applications Developed

### 1. Calculator with SQLite History
**Extended from Experiment 4**

#### Features
- **Calculation History Storage:** Every calculation (expression, result, timestamp) saved in SQLite database.  
- **History View:** Dedicated page showing all past calculations in chronological order.  
- **Delete Functionality:** Remove individual calculations.  
- **Persistent Storage:** Data remains after app restarts.  
- **Real-time Updates:** History updates automatically after each calculation.  

#### Key Implementation
- SQLite helper class for CRUD operations.  
- Automatic insertion of calculation records.  
- ListView to display history with delete options.  

---
[🎥 Watch demo video](https://raw.githubusercontent.com/manas-phal/Exp14_DataStorage/main/calculator.mp4)



### 2. To-Do List with SQLite Storage
**Extended from Experiment 5**

#### Features
- **Task Persistence:** All tasks stored in SQLite database.  
- **CRUD Operations:** Create, R
- ead, Update, Delete tasks.  
- **Automatic Loading:** Tasks loaded from database on startup.  
- **Status Management:** Track completion status of tasks.  
- **Permanent Storage:** Tasks remain after app restart.  

#### Key Implementation
- SQLite helper class for task management.  
- Integration with task form (add/update).  
- ListView connected to database queries.  
- Update/delete operations with UI synchronization.  

---

### 3. Student Registration Form with SQLite
**New Implementation**

#### Features
- **Form Fields:** `ID`, `Name`, `Email`, `Phone`, `Address`  
- **Persistent Storage:** Student data stored permanently in SQLite.  
- **CRUD Operations:**  
  - Insert student data from form  
  - Display students in ListView/RecyclerView  
  - Update email or other fields  
  - Delete individual student records  

#### Database Table Structure
| Column Name | Type        | Description               |
|------------|------------|---------------------------|
| id         | INTEGER PK | Unique student ID         |
| name       | TEXT       | Student name              |
| email      | TEXT       | Student email             |
| phone      | TEXT       | Student phone number      |
| address    | TEXT       | Student address           |

#### Implementation Steps
1. **Create Database & Table** – Using SQLiteOpenHelper (Android) or SQLite helper class (Flutter/React Native).  
2. **Insert** – Add student data from the form.  
3. **Query** – Retrieve and display all student records.  
4. **Update** – Modify student email or other details.  
5. **Delete** – Remove student record from the database.  

---

## Technical Implementation

### Database Process
1. **Create Database** → Define tables & schema  
2. **Insert** → Add new data entries  
3. **Query** → Retrieve and display data  
4. **Update** → Modify existing entries  
5. **Delete** → Remove specific records  

### Technologies Used
- **Flutter/Dart** for mobile app development  
- **SQLite** for local database storage  
- **SQLite Helper Classes** for database operations  
- **ListView/RecyclerView** for displaying records  

---
