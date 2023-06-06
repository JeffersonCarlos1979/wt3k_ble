import 'dart:typed_data';

class BitConverter {
  static int toInt32(List<int> intArray, int index) {
    int num = Int8List.fromList(
      intArray,
    ).buffer.asByteData().getInt32(index, Endian.little);
    return num;
  }
}
