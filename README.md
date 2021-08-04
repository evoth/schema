# Schema

## Plan

An all-in-one customizable approach to managing notes, tasks, events, and more.

## Current State

An extremely simple notes app with the very beginnings of responsive design. And in this version I haven't added data storage.
- Added an edit screen with a delete button.
- More advanced note display

## Todo

- Use Widget.of(context).function() instead of callbacks?
- Eliminate hard-coded values and gather them in one place as constants
- **Make public variables that should be private private**
   - Did this then probably made some more unwittingly public variables
- Fix codestyle
   - Once again, added some commas to make the formatter happy, then maybe messed it up some
- **Stateful vs Stateless**
- Make values const that should be const
- Figure out if what I'm doing with null safety in reguard to noteWidgetData is fine
   - Slowly phasing out the need to pass down notes
- Use keys instead of whatever else I'm doing