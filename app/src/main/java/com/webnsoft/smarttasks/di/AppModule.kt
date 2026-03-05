package com.webnsoft.smarttasks.di

import android.content.Context
import androidx.room.Room
import com.webnsoft.smarttasks.data.Api.MockNoteApi
import com.webnsoft.smarttasks.data.Api.NoteApi
import com.webnsoft.smarttasks.data.local.NoteDao
import com.webnsoft.smarttasks.data.local.NoteDatabase

import com.webnsoft.smarttasks.data.repository.NoteRepository
import com.webnsoft.smarttasks.domain.usecase.NoteUseCases
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideDatabase(
        @ApplicationContext app: Context
    ): NoteDatabase =
        Room.databaseBuilder(
            app,
            NoteDatabase::class.java,
            "notes_db"
        ).build()

    @Provides
    @Singleton
    fun provideNoteDao(db: NoteDatabase): NoteDao =
        db.noteDao()

    @Provides
    @Singleton
    fun provideNoteApi(): NoteApi =
        MockNoteApi()

    @Provides
    @Singleton
    fun provideRepository(
        dao: NoteDao,
        api: NoteApi
    ): NoteRepository =
        NoteRepository(dao, api)

    @Provides
    @Singleton
    fun provideUseCases(
        repository: NoteRepository
    ): NoteUseCases =
        NoteUseCases(repository)
}