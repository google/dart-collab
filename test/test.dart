//  Copyright 2011 Google Inc. All Rights Reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:collab/collab.dart';
import 'package:collab/server/server.dart';

// TODO: Really need a client/server integration test.
// Need OT scenarios across two clients with simultaneous operations.
main() {
  test('CollabServer Setup', () {
    var connection = new MockConnection();
    connection.when(callsTo('add', anything)).thenCall((message) {
      print("is ClientIdMessage: ${message is ClientIdMessage}");
      expect(message, new isInstanceOf<ClientIdMessage>('ClientIdMessage'));
    });

    var collabServer = new CollabServer();
    collabServer.addConnection(connection);
  });
}

class MockConnection extends Mock implements Connection {}
