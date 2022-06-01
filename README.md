# Schema

## (Revised) Plan

Functional notes app with features like labels/categories and cloud storage.

## Current State

A simple notes app with ability to access notes across separate devices.
- Notes are now uploaded to and downloaded from Cloud Firestore.
- Currently, all notes are downloaded on loading of the app. In the future, I would like to have it selectively download only the notes that have changed.

## Todo
- Optimize initial note download
- Think more about how transfers will work (Cloud Functions)
- Old todo (need to look into these at some point)
   - Make public variables that should be private private
   - Figure out if what I'm doing with null safety in reguard to noteWidgetData is fine
      - Slowly phasing out the need to pass down notes
   - Use keys instead of whatever else I'm doing