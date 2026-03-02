package com.webnsoft.smarttasks.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.webnsoft.smarttasks.data.model.Note

@Database(entities = [Note::class], version = 1)
abstract class NoteDatabase : RoomDatabase() {
    abstract fun noteDao(): NoteDao
}