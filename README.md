# Schema

## (Revised) Plan

Functional notes app with features like labels/categories and cloud storage.

## Current State

A simple notes app with ability to access notes across separate devices.
- Added side drawer to manage account and edit labels.
   - In the future, will transfer notes from anonymous account to Google account
   - Also, will filter by a label when that label is pressed
- Currently, all notes are downloaded on loading of the app. In the future, I would like to have it selectively download only the notes that have changed.

## Todo
- Optimize initial note download
- Think about ordering of notes and labels
- Think more about how transfers will work (Cloud Functions)
- Make widgets like Text() const
- Make it so you can't go back to loading screen
- Old todo (need to look into these at some point)
   - Make public variables that should be private private
   - Figure out if what I'm doing with null safety in reguard to noteWidgetData is fine
      - Slowly phasing out the need to pass down notes
   - Use keys instead of whatever else I'm doing