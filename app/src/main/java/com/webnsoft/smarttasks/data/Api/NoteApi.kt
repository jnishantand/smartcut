package com.webnsoft.smarttasks.data.remote

import com.webnsoft.smarttasks.data.model.Note
import kotlinx.coroutines.delay

interface NoteApi {
    suspend fun getNotesFromApi(): List<Note>
}

// Mock implementation
class MockNoteApi : NoteApi {
    override suspend fun getNotesFromApi(): List<Note> {
        delay(1000) // simulate network delay
        return listOf(
            Note(id = 1, title = "API Note 1", description = "Content 1"),
            Note(id = 2, title = "API Note 2", description = "Content 2")
        )
    }
}