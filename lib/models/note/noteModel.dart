// It's a note, what can I say
class Note {
  int id;
  int index;
  int tempIndex;
  String title;
  String text;
  bool drag;
  double dragX = 0;
  double dragY = 0;
  bool deleted;

  Note(
    this.id,
    this.index,
    this.title,
    this.text,
    this.tempIndex,
    this.drag, {
    this.deleted = false,
  });
}
