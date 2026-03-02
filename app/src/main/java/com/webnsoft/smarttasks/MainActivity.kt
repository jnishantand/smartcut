package com.webnsoft.smarttasks

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.webnsoft.smarttasks.data.model.Note
import com.webnsoft.smarttasks.presentation.NoteViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val viewModel: NoteViewModel = hiltViewModel()
            val notes by viewModel.notes.collectAsState()

            var showDialog by remember {
                mutableStateOf(
                    false
                )
            }
            var selectedNote by remember { mutableStateOf<Note?>(null) }

            Scaffold(
                //topBar = { Text("Notes", modifier = Modifier.width(width = 100.dp)) },
                floatingActionButton = {
                    FloatingActionButton(onClick = { showDialog = true }) {
                        Text("Add")
                    }
                }
            ) { padding ->
                Column {
                   Card(modifier = Modifier.background(Color.Blue.copy(alpha = 0.05f)).fillMaxWidth().padding(10.dp)) { Text("To Do Tasks", modifier = Modifier.fillMaxWidth().padding(10.dp))
                   }
                    LazyColumn(
                        modifier = Modifier
                            .padding(padding)
                            .fillMaxSize(),
                        contentPadding = PaddingValues(16.dp)
                    )

                    {


                        items(notes) { note ->

                            NoteItem(
                                note = note,
                                onDelete = { viewModel.deleteNote(it) },
                                update = { selectedNote = note }   // 👈 pass actual note
                            )
                        }

                    }

                    if (showDialog) {
                        AddNoteDialog(
                            onAdd = { title, description ->
                                viewModel.addNote(Note(title = title, description = description))
                                showDialog = false
                            },
                            onDismiss = { showDialog = false }
                        )
                    }
                    selectedNote?.let { note ->
                        UpdateNoteDialog(
                            note = note,
                            onUpdate = { title, description ->
                                viewModel.updateNote(
                                    note.copy(title = title, description = description)
                                )
                                selectedNote = null
                            },
                            onDismiss = { selectedNote = null }
                        )
                    }
                }
            }
        }
    }
}


@Composable
fun AddNoteDialog(onAdd: (String, String) -> Unit, onDismiss: () -> Unit) {
    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }



    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Note") },
        text = {
            Column {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Title") }
                )
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = description,
                    onValueChange = { description = it },
                    label = { Text("Description") }
                )
            }
        },
        confirmButton = {
            Button(onClick = { onAdd(title, description) }) {
                Text("Add")
            }
        },
        dismissButton = {
            Button(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun UpdateNoteDialog(
    note: Note,
    onUpdate: (String, String) -> Unit,
    onDismiss: () -> Unit
) {
    var title by remember { mutableStateOf(note.title) }
    var description by remember { mutableStateOf(note.description) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Update Note") },
        text = {
            Column {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Title") }
                )
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = description,
                    onValueChange = { description = it },
                    label = { Text("Description") }
                )
            }
        },
        confirmButton = {
            Button(onClick = { onUpdate(title, description) }) {
                Text("Update")
            }
        },
        dismissButton = {
            Button(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
@Composable
fun NoteItem(note: Note, onDelete: (Note) -> Unit,update:()->Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)

    ) {
        Row(modifier = Modifier.padding(16.dp).fillMaxWidth(), horizontalArrangement = Arrangement.Start) {
            Column {
                Text(text = note.title, style = MaterialTheme.typography.titleMedium)
                Text(text = note.description, style = MaterialTheme.typography.bodyMedium)
            }
            Spacer(modifier = Modifier.weight(1f))
            Button(onClick = {update()}) { Text("Update") }
            Button(onClick = {onDelete(note) }) { Text("Delete") }
        }
    }
}