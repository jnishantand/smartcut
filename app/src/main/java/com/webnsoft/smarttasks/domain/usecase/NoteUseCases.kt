package com.webnsoft.smarttasks.domain.usecase

import com.webnsoft.smarttasks.data.model.Note
import com.webnsoft.smarttasks.data.repository.NoteRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class NoteUseCases @Inject constructor(
    private val repository: NoteRepository
) {
    fun getNotes(): Flow<List<Note>> = repository.getNotes()
    suspend fun fetchNotesFromApi() = repository.fetchNotesFromApi()
    suspend fun addNote(note: Note) = repository.addNote(note)
    suspend fun deleteNote(note: Note) = repository.deleteNote(note)
    suspend fun updateNote(note: Note)=repository.updateNote(note)
}