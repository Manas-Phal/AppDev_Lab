import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: " AIzaSyCZW3wczAIZFuUN0NP0dHAIEbdbCqqa87c",
  authDomain: "your-app.firebaseapp.com",
  projectId: "crud-4de7a",
  storageBucket: "your-app.appspot.com",
  messagingSenderId: "896557574493",
  appId: "1:896557574493:android:8a30cd99f44f2c0dada0b4",
};

const app = initializeApp(firebaseConfig);
export const dB=getFirestore(app);
