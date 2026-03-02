package com.webnsoft.smarttasks.data.repository

import com.webnsoft.smarttasks.data.local.NoteDao
import com.webnsoft.smarttasks.data.model.Note
import com.webnsoft.smarttasks.data.remote.NoteApi
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class NoteRepository @Inject constructor(
    private val dao: NoteDao,
    private val api: NoteApi
) {
    fun getNotes(): Flow<List<Note>> = dao.getNotes()

    // Fetch notes from API and save to local DB
    suspend fun fetchNotesFromApi() {
        val apiNotes = api.getNotesFromApi()
        apiNotes.forEach { dao.addNote(it) }
    }

    suspend fun addNote(note: Note) = dao.addNote(note)
    suspend fun deleteNote(note: Note) = dao.deleteNote(note)
    suspend fun updateNote(note: Note)=dao.updateNote(note)
}