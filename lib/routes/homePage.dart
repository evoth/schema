import 'dart:async';
import 'package:alert_dialog/alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/layout/grid.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/layoutEditWidget.dart';
import 'package:schema/widgets/themeEditWidget.dart';
import 'package:schema/widgets/homeDrawerWidget.dart';

// Home page to view notes and drawer to edit labels
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data used to edit and filter labels
  late LabelsData labelsData =
      LabelsData(null, () => setState(() {}), filterLabel);

  // Whether the app is loading
  bool isLoading = false;

  // Whether the widget is new (we shouldn't update if it is, since it was
  // already updated earlier)
  bool isNew = true;

  // Adds a new blank note
  void newNote() async {
    Note newNote = noteData.newNote(labelsData.filterLabelId);
    // Go to the edit screen for the new note
    await noteData.editNote(
      NoteWidgetData(
        newNote,
        () => setState(() {}),
        filterLabelId: labelsData.filterLabelId,
      ),
      () => setState(() {}),
    );
  }

  // Updates notes while showing loading symbol, prevents concurrent updates
  void updateNotesAndShowLoading(String? labelId) async {
    if (!isLoading) {
      isLoading = true;
      setState(() {});
      await noteData.updateNotes(labelId);
      isLoading = false;
      setState(() {});
    }
  }

  // Filters by the given label (if null, stops filtering and shows all notes)
  void filterLabel(String? labelId) async {
    labelsData.filterLabelId = labelId;
    Navigator.of(context).pop();
    updateNotesAndShowLoading(labelId);
  }

  // Stream subscription for note metadata document
  late StreamSubscription<DocumentSnapshot<Object?>> dataDocSubscription;

  // Listener to update notes when back online
  late void Function() backOnlineListener;

  // Subscribes to document
  @override
  void initState() {
    // Deals with data if we were deleting/transferring
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (noteData.isDeleting) {
        noteData.isDeleting = false;
        updateNotesAndShowLoading(labelsData.filterLabelId);
        // Shows transfer complete message if applicable
        if (noteData.isTransferring) {
          noteData.isTransferring = false;
          showAlert(Constants.transferCompleteMessage);
        }
      }
    });

    // Updates notes whenever the metadata document is updated from a different
    // device and the new data is different from the current data
    dataDocSubscription =
        noteData.noteDataDocRef(forceOnline: true).snapshots().listen(
      (event) async {
        // Removes timeUpdated from each so that it doesn't affect equality
        Map<String, dynamic> newNoteDataMap =
            event.data() as Map<String, dynamic>;
        newNoteDataMap.remove("timeUpdated");
        Map<String, dynamic> noteDataMap = noteData.toJson();
        noteDataMap.remove("timeUpdated");
        // Evaluates necessary conditions and updates notes if needed
        if (noteData.isOnline &&
            !isNew &&
            !noteData.isDeleting &&
            noteData.ownerId != null &&
            event.data() != null &&
            !event.metadata.hasPendingWrites &&
            !DeepCollectionEquality().equals(
              newNoteDataMap,
              noteDataMap,
            )) {
          updateNotesAndShowLoading(labelsData.filterLabelId);
        }
        isNew = false;
      },
    );

    // Updates notes when we have just gone back online so we can merge them
    backOnlineListener = () {
      if (noteData.backOnlineNotifier.value) {
        updateNotesAndShowLoading(
          labelsData.filterLabelId,
        );
      }
    };

    noteData.backOnlineNotifier.addListener(backOnlineListener);

    super.initState();
  }

  // Cancels note metadata document listener
  @override
  void dispose() {
    noteData.backOnlineNotifier.removeListener(backOnlineListener);
    dataDocSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If user taps outside of text fields, unfocus (and dismiss keyboard)
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        // Row to conditionally display loading indicator
        title: Row(
          children: [
            // If filtering, filter name. Otherwise, "Schema"
            this.mounted && labelsData.filterLabelId != null
                ? Text(noteData.getLabelName(labelsData.filterLabelId!))
                : Text(Constants.appTitle),
            SizedBox(width: Constants.appBarPadding),
            // Loading symbol if we are loading
            SizedBox(
              height: Constants.appBarSize,
              width: Constants.appBarSize,
              child: Center(
                child: isLoading ? CircularProgressIndicator() : null,
              ),
            ),
          ],
        ),
        elevation: 0,
        // App bar actions
        actions: [
          // Note shape / layout button
          IconButton(
            onPressed: () {
              alert(
                context,
                title: Text(Constants.layoutEditTitle),
                content: LayoutEditContent(refresh: () => setState(() {})),
                textOK: Text(Constants.layoutEditOK),
              );
            },
            tooltip: Constants.layoutTip,
            icon: Icon(Icons.grid_view_rounded),
          ),
          SizedBox(width: Constants.appBarPadding),
          // Theme edit button
          IconButton(
            onPressed: () {
              alert(
                context,
                title: Text(Constants.themeEditTitle),
                content: ThemeEditContent(),
                textOK: Text(Constants.themeEditOK),
              );
            },
            tooltip: Constants.themeTip,
            icon: Icon(Icons.color_lens),
          ),
          SizedBox(width: Constants.appBarPadding),
        ],
      ),
      // Drawer with settings, labels, etc
      drawer: HomeDrawer(labelsData),
      // Saves label name when drawer is closed
      onDrawerChanged: (isOpen) {
        if (!isOpen) {
          // Saves label name if one was being edited
          if (labelsData.labelsEditMode &&
              labelsData.editLabelId != '' &&
              labelsData.labelName != null &&
              labelsData.labelName !=
                  noteData.getLabelName(labelsData.editLabelId)) {
            noteData.editLabelName(
              labelsData.editLabelId,
              labelsData.labelName!,
            );
          }
          // Resets data
          labelsData.resetEditing();
          setState(() {});
        }
      },
      // Stack so that buttons can go over the grid
      body: Stack(
        children: <Widget>[
          // Grid with notes
          DynamicGrid(
            refreshNotes: () => setState(() {}),
            filterLabelId: labelsData.filterLabelId,
            // Rebuilds when the filter id or layout changes
            key: ValueKey(labelsData.filterLabelId ??
                '' + noteData.layoutDimensionId.toString()),
          ),
          // Add note button
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(Constants.homePadding),
            child: FloatingActionButton(
              onPressed: newNote,
              tooltip: Constants.newNoteTip,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

// This is necessary (as opposed to keeping a state in the drawer widget)
// solely because we need to access and update this when the drawer widget
// doesn't exist, such as right after it is closed
class LabelsData {
  // Whether the labels section is in edit mode
  bool labelsEditMode = false;
  // Which label is in name edit mode (empty string for none)
  String editLabelId = '';
  // Current edited label name
  String? labelName;
  // Filtering label
  String? filterLabelId;
  // Function for refreshing the home page
  final Function refreshNotes;
  // Function to filter by a label
  final Function filterLabel;

  // Resets variables related to label editing
  void resetEditing() {
    labelsEditMode = false;
    editLabelId = '';
    labelName = null;
  }

  LabelsData(this.filterLabelId, this.refreshNotes, this.filterLabel);
}
