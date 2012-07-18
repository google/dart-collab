
typedef Operation Transform(Operation op1, Operation op2);

/*
 * Operations modify a document.
 */
class Operation extends Message {
  
  static Map<String, Map<String, Transform>> _getTransforms() => {
    "text": {"text": TextOperation.transformInsert},
  };
  
  /*
   * Transform [Operation] [op] by [by].
   * 
   * It's important that these sequences of operation result in the same
   * changes:
   * 
   * op1.apply(doc);
   * var op2t = Operation.transform(op2, op1);
   * op2t.apply(doc);
   * 
   * op2.apply(doc);
   * var op1t = Operation.transform(op1, op2);
   * op1t.apply(doc);
   */
  static Operation transform(Operation op, Operation by) {
    if (_getTransforms()[op.type] == null) {
      return op;
    }
    Transform t = _getTransforms()[op.type][by.type];
    if (t == null) {
      return op;
    }
    return t(op, by);
  }
  
  final String docId;
  // set when op created to the doc version of the client
  final int docVersion;
  // set when an operation is applied by the server
  int sequence;
  
  Operation(String type, String senderId, this.docId, this.docVersion) 
    : super(type, senderId);
  
  Operation.fromMap(Map<String, Object> map) 
    : super.fromMap(map),
      docId = map['docId'],
      docVersion = map['docVersion'],
      sequence = map['sequence'];
  
  Map<String, Object> toMap([values]) => super.toMap(mergeMaps(values, {
      'docId': docId, 'docVersion': docVersion, 'sequence': sequence}));
  
  abstract void apply(Document document);
}
