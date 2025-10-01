App.js
// References
const notebookList = document.getElementById("notebookList");
const notesContainer = document.getElementById("notesContainer");
const activeNotebookTitle = document.getElementById("activeNotebook");
const addNotebookBtn = document.getElementById("addNotebookBtn");
const addNoteBtn = document.getElementById("addNoteBtn");
const themeToggle = document.getElementById("themeToggle");

// Modal refs
const noteModal = document.getElementById("noteModal");
const modalTitle = document.getElementById("modalTitle");
const noteTitleInput = document.getElementById("noteTitle");
const noteContentInput = document.getElementById("noteContent");
const saveNoteBtn = document.getElementById("saveNoteBtn");
const cancelNoteBtn = document.getElementById("cancelNoteBtn");

let appData = loadData();
let activeNotebook = null;
let editingNoteId = null;

// Render Notebooks
function renderNotebooks() {
  notebookList.innerHTML = "";
  Object.keys(appData.notebooks).forEach(name => {
    const li = document.createElement("li");
    li.textContent = name;
    li.classList.add("notebook-item");
    if (name === activeNotebook) li.classList.add("active");
    li.onclick = () => switchNotebook(name);
    notebookList.appendChild(li);
  });
}

// Switch Notebook
function switchNotebook(name) {
  activeNotebook = name;
  activeNotebookTitle.textContent = name;
  renderNotes();
  renderNotebooks();
}

// Render Notes
function renderNotes() {
  notesContainer.innerHTML = "";
  if (!activeNotebook) return;
  const notes = appData.notebooks[activeNotebook] || [];

  notes.forEach(note => {
    const card = document.createElement("div");
    card.className = "note-card";

    const title = document.createElement("h3");
    title.textContent = note.title;

    const content = document.createElement("p");
    content.textContent = note.content;

    const actions = document.createElement("div");
    actions.className = "note-actions";

    const editBtn = document.createElement("button");
    editBtn.textContent = "Edit";
    editBtn.className = "edit";
    editBtn.onclick = () => openModal(note.id);

    const deleteBtn = document.createElement("button");
    deleteBtn.textContent = "Delete";
    deleteBtn.className = "delete";
    deleteBtn.onclick = () => deleteNote(note.id);

    actions.appendChild(editBtn);
    actions.appendChild(deleteBtn);

    card.appendChild(title);
    card.appendChild(content);
    card.appendChild(actions);

    notesContainer.appendChild(card);
  });
}

// Add Notebook
addNotebookBtn.onclick = () => {
  const name = prompt("Notebook name:");
  if (name && !appData.notebooks[name]) {
    appData.notebooks[name] = [];
    saveData(appData);
    renderNotebooks();
  }
};

// Add Note
addNoteBtn.onclick = () => {
  if (!activeNotebook) {
    alert("Please select a notebook first.");
    return;
  }
  openModal();
};

// Open Modal
function openModal(noteId = null) {
  editingNoteId = noteId;
  if (noteId) {
    const note = appData.notebooks[activeNotebook].find(n => n.id === noteId);
    noteTitleInput.value = note.title;
    noteContentInput.value = note.content;
    modalTitle.textContent = "Edit Note";
  } else {
    noteTitleInput.value = "";
    noteContentInput.value = "";
    modalTitle.textContent = "New Note";
  }
  noteModal.style.display = "flex";
}

// Save Note
saveNoteBtn.onclick = () => {
  const title = noteTitleInput.value.trim();
  const content = noteContentInput.value.trim();
  if (!title) return alert("Title is required!");

  let notes = appData.notebooks[activeNotebook];
  if (editingNoteId) {
    const note = notes.find(n => n.id === editingNoteId);
    note.title = title;
    note.content = content;
  } else {
    notes.push({ id: Date.now(), title, content });
  }
  saveData(appData);
  renderNotes();
  closeModal();
};

// Delete Note
function deleteNote(noteId) {
  if (!confirm("Are you sure you want to delete this note?")) return;
  appData.notebooks[activeNotebook] =
    appData.notebooks[activeNotebook].filter(n => n.id !== noteId);
  saveData(appData);
  renderNotes();
}

// Cancel Modal
cancelNoteBtn.onclick = closeModal;
function closeModal() {
  noteModal.style.display = "none";
  editingNoteId = null;
}

// Theme Toggle
themeToggle.onclick = () => {
  document.body.classList.toggle("dark");
};

// Init
if (Object.keys(appData.notebooks).length > 0) {
  const firstNotebook = Object.keys(appData.notebooks)[0];
  switchNotebook(firstNotebook);
}
renderNotebooks();

//storage.js
// Utility functions for Local Storage
const STORAGE_KEY = "notesAppData";

function loadData() {
  const data = localStorage.getItem(STORAGE_KEY);
  return data ? JSON.parse(data) : { notebooks: {} };
}

function saveData(data) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}








