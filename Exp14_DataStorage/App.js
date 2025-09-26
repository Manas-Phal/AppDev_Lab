import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Button,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  Alert,
  Platform,
} from 'react-native';
import { createTables, insertStudent, getStudents, updateEmail, deleteStudent } from './db';

const App = () => {
  const [students, setStudents] = useState([]);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');
  const [course, setCourse] = useState('');
  const [year, setYear] = useState('');

  useEffect(() => {
    createTables();
    getStudents(setStudents);
  }, []);

  const addStudent = () => {
    if (!name || !email) {
      Alert.alert('Validation', 'Name & Email are required!');
      return;
    }
    insertStudent(name, email, phone, address, course, year);
    getStudents(setStudents);
    clearForm();
  };

  const clearForm = () => {
    setName('');
    setEmail('');
    setPhone('');
    setAddress('');
    setCourse('');
    setYear('');
  };

  const handleUpdate = (id) => {
    if (Platform.OS === "ios") {
      Alert.prompt("Update Email", "Enter new email:", (newEmail) => {
        if (newEmail) {
          updateEmail(id, newEmail);
          getStudents(setStudents);
        }
      });
    } else {
      const newEmail = "updated_" + Math.floor(Math.random() * 1000) + "@mail.com";
      updateEmail(id, newEmail);
      getStudents(setStudents);
      Alert.alert("Email Updated", `New email: ${newEmail}`);
    }
  };

  const handleDelete = (id) => {
    deleteStudent(id);
    getStudents(setStudents);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>📚 Student Registration</Text>

      <TextInput placeholder="Name" value={name} onChangeText={setName} style={styles.input} />
      <TextInput placeholder="Email" value={email} onChangeText={setEmail} style={styles.input} />
      <TextInput placeholder="Phone" value={phone} onChangeText={setPhone} style={styles.input} />
      <TextInput placeholder="Address" value={address} onChangeText={setAddress} style={styles.input} />
      <TextInput placeholder="Course" value={course} onChangeText={setCourse} style={styles.input} />
      <TextInput placeholder="Year" value={year} onChangeText={setYear} style={styles.input} />

      <Button title="Add Student" onPress={addStudent} />

      <FlatList
        data={students}
        keyExtractor={item => item.id.toString()}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.name}>{item.name} ({item.course} - {item.year})</Text>
            <Text>Email: {item.email}</Text>
            <Text>Phone: {item.phone}</Text>
            <Text>Address: {item.address}</Text>
            <Text style={styles.time}>Added on: {item.created_at}</Text>

            <View style={styles.row}>
              <TouchableOpacity onPress={() => handleUpdate(item.id)} style={styles.btnUpdate}>
                <Text style={styles.btnText}>Update</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={() => handleDelete(item.id)} style={styles.btnDelete}>
                <Text style={styles.btnText}>Delete</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}
      />
    </View>
  );
};

export default App;

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: "#fff" },
  heading: { fontSize: 20, fontWeight: 'bold', marginBottom: 10 },
  input: { borderWidth: 1, borderColor: "#ccc", marginBottom: 10, padding: 8, borderRadius: 5 },
  card: { padding: 10, marginVertical: 5, backgroundColor: "#f2f2f2", borderRadius: 5 },
  row: { flexDirection: "row", justifyContent: "space-between", marginTop: 5 },
  btnUpdate: { backgroundColor: "blue", padding: 5, borderRadius: 5 },
  btnDelete: { backgroundColor: "red", padding: 5, borderRadius: 5 },
  btnText: { color: "#fff" },
  name: { fontWeight: "bold", fontSize: 16 },
  time: { fontSize: 12, color: "gray", marginTop: 3 },
});
