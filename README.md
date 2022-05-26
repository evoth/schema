# Schema

## (Revised) Plan

Functional notes app with features like labels/categories and cloud storage.

## Current State

An extremely simple notes app. And in this version I haven't added data storage.
- Fixed a bug where deleting a new note wouldn't initially delete it.
- Cleaned up the code a little (coming back to this after 10 months).

## Todo

- Use Widget.of(context).function() instead of callbacks?
- Make public variables that should be private private
- Figure out if what I'm doing with null safety in reguard to noteWidgetData is fine
   - Slowly phasing out the need to pass down notes
- Use keys instead of whatever else I'm doing