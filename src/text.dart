//#library('text');
//
//#import('document.dart');
//#import('operation.dart');
//#import('utils.dart');

/*
 * Inserts a string into a text document.
 */
class TextOperation extends Operation {
  final int position;
  final String deleted;
  final String inserted;
  
  TextOperation(String senderId, String docId, int docVersion, this.position, this.deleted, this.inserted)
    : super("text", senderId, docId, docVersion);
  
  TextOperation.fromMap(Map<String, Object> map)
    : super.fromMap(map),
      position = map['position'],
      deleted = map['deleted'],
      inserted = map['inserted'];
  
  toMap([values]) => super.toMap(mergeMaps(values, {
      'position': position, 'deleted': deleted, 'inserted': inserted}));
  
  void apply(Document document) {
    document.modify(position, deleted, inserted);
  }
  
  static TextOperation transformInsert(TextOperation op, TextOperation by) {
    int newPosition = (by.position < op.position)
        ? op.position + (by.inserted.length - by.deleted.length)
        : op.position;
    // should docVersion be updated?
    // should [by] have to have a sequence number?
    // A: yes, and it should be less than op.docVersion
    return new TextOperation(op.senderId, op.docId, op.docVersion, newPosition, op.deleted, op.inserted);
  }
}
