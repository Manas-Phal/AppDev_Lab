// Import the necessary functions from Firebase SDK (v9+ Modular)
import { initializeApp } from 'firebase/app';
import { getFirestore, enablePersistence, CACHE_SIZE_UNLIMITED } from 'firebase/firestore';

// Your Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyCZW3wczAIZFuUN0NP0dHAIEbdbCqqa87c",
  authDomain: "your-app.firebaseapp.com",
  projectId: "crud-4de7a",
  storageBucket: "your-app.appspot.com",
  messagingSenderId: "896557574493",
  appId: "1:896557574493:android:8a30cd99f44f2c0dada0b4",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Get Firestore instance
const db = getFirestore(app);

// Enable Firestore offline support
enablePersistence(db, { experimentalTabSynchronization: true })
  .catch((err) => {
    if (err.code === 'failed-precondition') {
      // Multiple tabs open in browser
      console.log("Persistence failed - multiple tabs open");
    } else if (err.code === 'unimplemented') {
      // Browser does not support persistence
      console.log("Persistence is not available in this environment");
    }
  });

export { db };

