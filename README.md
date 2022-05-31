# Schema

## (Revised) Plan

Functional notes app with features like labels/categories and cloud storage.

## Current State

An extremely simple notes app. And in this version I haven't added data storage.
- Changed a lot of things under the hood to prepare for updating and downloading notes from cloud

## Todo
- Make it so notes are downloaded on app start and update as needed
- Think more about how transfers will work (Cloud Functions)
- Old todo (need to look into these at some point)
   - Make public variables that should be private private
   - Figure out if what I'm doing with null safety in reguard to noteWidgetData is fine
      - Slowly phasing out the need to pass down notes
   - Use keys instead of whatever else I'm doing