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

library utils;

import 'dart:math';

const String ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

final Random _random = new Random();

String randomId() {
  StringBuffer sb = new StringBuffer();
  for (int i = 0; i < 12; i++) {
    sb.write(ALPHABET[_random.nextInt(ALPHABET.length)]);
  }
  return sb.toString();
}

Map<String, Object> mergeMaps(Map<String, Object> a, Map<String, Object> b) {
  Map<String, Object> merged = (a == null) ? new Map() : new Map.from(a);
  b.forEach((k, v) { merged[k] = v; });
  return merged;
}
