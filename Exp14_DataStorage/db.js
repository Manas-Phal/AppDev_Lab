import SQLite from 'react-native-sqlite-storage';

const db = SQLite.openDatabase(
  { name: 'SchoolDB.db', location: 'default' },
  () => console.log('DB Opened'),
  error => console.log('DB Error: ' + error)
);

// Create table
export const createTables = () => {
  db.transaction(txn => {
    txn.executeSql(
      `CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT,
        address TEXT,
        course TEXT,
        year TEXT,
        created_at TEXT
      );`,
      [],
      () => console.log('Table created successfully'),
      error => console.log('Error creating table ' + error.message)
    );
  });
};

// Insert new student with timestamp
export const insertStudent = (name, email, phone, address, course, year) => {
  const timestamp = new Date().toLocaleString();
  db.transaction(txn => {
    txn.executeSql(
      `INSERT INTO students (name, email, phone, address, course, year, created_at) VALUES (?,?,?,?,?,?,?)`,
      [name, email, phone, address, course, year, timestamp],
      () => console.log('Student Inserted'),
      error => console.log('Insert error ' + error.message)
    );
  });
};

// Get all students
export const getStudents = (setStudents) => {
  db.transaction(txn => {
    txn.executeSql(
      `SELECT * FROM students ORDER BY id DESC`,
      [],
      (sqlTxn, res) => {
        let results = [];
        for (let i = 0; i < res.rows.length; i++) {
          results.push(res.rows.item(i));
        }
        setStudents(results);
      },
      error => console.log('Fetch error ' + error.message)
    );
  });
};

// Update email
export const updateEmail = (id, newEmail) => {
  db.transaction(txn => {
    txn.executeSql(
      `UPDATE students SET email = ? WHERE id = ?`,
      [newEmail, id],
      () => console.log('Email Updated'),
      error => console.log('Update error ' + error.message)
    );
  });
};

// Delete student
export const deleteStudent = (id) => {
  db.transaction(txn => {
    txn.executeSql(
      `DELETE FROM students WHERE id = ?`,
      [id],
      () => console.log('Deleted Successfully'),
      error => console.log('Delete error ' + error.message)
    );
  });
};

export default db;
