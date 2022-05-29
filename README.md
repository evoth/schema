# Schema

## (Revised) Plan

Functional notes app with features like labels/categories and cloud storage.

## Current State

An extremely simple notes app. And in this version I haven't added data storage.
- Moved around and cleaned up more things
- Added sign in screen and sign in functionality, although it's not used for anything yet
- Did a lot of work to get Firebase, Firestore, Authentication, and Hosting working smoothly

## Todo
- Make it so notes are downloaded on app start and updated as needed
- Figure out what the notes data document will consist of
   - Date registered
   - Note counters and stuff
   - Note ordering (map)
   - Other stuff probably
- Think more about how transfers will work (Cloud Functions)
- Old todo (need to look into these at some point)
   - Make public variables that should be private private
   - Figure out if what I'm doing with null safety in reguard to noteWidgetData is fine
      - Slowly phasing out the need to pass down notes
   - Use keys instead of whatever else I'm doing