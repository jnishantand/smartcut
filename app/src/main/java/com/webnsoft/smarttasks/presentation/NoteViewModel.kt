package com.webnsoft.smarttasks.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.webnsoft.smarttasks.domain.usecase.NoteUseCases
import com.webnsoft.smarttasks.data.model.Note
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class NoteViewModel @Inject constructor(
    private val useCases: NoteUseCases
) : ViewModel() {

    private val _notes = MutableStateFlow<List<Note>>(emptyList())
    val notes: StateFlow<List<Note>> = _notes

    init {


        viewModelScope.launch {
            useCases.fetchNotesFromApi()
            useCases.getNotes().collect { _notes.value = it }
        }
    }

    fun addNote(note: Note) = viewModelScope.launch { useCases.addNote(note) }
    fun deleteNote(note: Note) = viewModelScope.launch { useCases.deleteNote(note) }
    fun  updateNote(note: Note)= viewModelScope.launch { useCases.updateNote(note) }
}