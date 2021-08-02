// Easy way to store and pass all the data needed by notes widgets at multiple levels
class NoteWidgetData {
  final int index;
  final int id;
  final String title;
  final String text;
  final Function edit;
  final Function delete;
  // Need these to be available, but they're only added in grid. Figure out how to make optional
  final Function drag1;
  final Function drag2;
  final double originalX;
  final double originalY;

  NoteWidgetData(this.edit, this.delete, this.drag1, this.drag2,
      {this.index = 0,
      this.id = 0,
      this.title = "",
      this.text = "",
      this.originalX = 0,
      this.originalY = 0});
}
