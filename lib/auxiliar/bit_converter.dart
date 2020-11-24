import 'dart:typed_data';

/**
 * Created by jeffe on 20/11/2020.
 */

class BitConverter {
  static int toInt32(List<int> intArray, int index) {
    int num = Int8List.fromList(
      intArray,
    ).buffer.asByteData().getInt32(index, Endian.little);
    return num;
  }
}