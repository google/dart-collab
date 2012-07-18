#import('../../../Downloads/dart/dart-sdk/lib/unittest/unittest.dart');
#import('../src/collab.dart');
#import('../src/server/server.dart');

// TODO: Really need a client/server integration test.
// Abstracting out Transport is the first step.
// Need OT scenarios across two clients with simultaneous operations.
main() {
  test('CollabServer Setup', () {
    var transport = new MockTransport();
    var connection = new MockConnection();
    var onOpenCallback;
    transport.when(callsTo('set:onOpen', anything)).thenCall((callback) {
      onOpenCallback = callback;
    });
    
    var collabServer = new CollabServer(transport);
    expect(onOpenCallback, isNotNull);
    
    connection.when(callsTo('send', anything)).thenCall((message) {
      expect(message, new isInstanceOf<ClientIdMessage>());
    });
    onOpenCallback(connection);
    
  });
}

class MockTransport extends Mock implements Transport {}
class MockConnection extends Mock implements Connection {}



//LoggingMatcher log(matcher) => new LoggingMatcher(wrapMatcher(matcher));
//
//class LoggingMatcher implements Matcher {
//  Matcher matcher;
//  bool called = false;
//  
//  LoggingMatcher(this.matcher);
//  
//  bool matches(item) {
//    if (called) {
//      throw "called already";
//    }
//    bool m = matcher.matches(item);
//    print("$item matches = $m");
//    called = true;
//    return m;
//  }
//
//  Description describe(Description description) => matcher.describe(description);
//
//  Description describeMismatch(item, Description mismatchDescription) =>
//      matcher.describeMismatch(item, mismatchDescription);
//
//}