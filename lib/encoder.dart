class Encoder {
  static Map<String, String> _encode = {
    "a": "q",
    "b": "w",
    "c": "e",
    "d": "a",
    "e": "s",
    "f": "d",
    "g": "z",
    "h": "x",
    "i": "c",
    "j": "r",
    "k": "t",
    "l": "y",
    "m": "f",
    "n": "g",
    "o": "h",
    "p": "v",
    "q": "b",
    "r": "n",
    "s": "u",
    "t": "i",
    "u": "o",
    "v": "p",
    "w": "j",
    "x": "k",
    "y": "l",
    "z": "m",
    "A": "Q",
    "B": "W",
    "C": "E",
    "D": "A",
    "E": "S",
    "F": "D",
    "G": "Z",
    "H": "X",
    "I": "C",
    "J": "R",
    "K": "T",
    "L": "Y",
    "M": "F",
    "N": "G",
    "O": "H",
    "P": "V",
    "Q": "B",
    "R": "N",
    "S": "U",
    "T": "I",
    "U": "O",
    "V": "P",
    "W": "J",
    "X": "K",
    "Y": "L",
    "Z": "M",
    "1": "4",
    "2": "3",
    "3": "5",
    "4": "7",
    "5": "6",
    "6": "8",
    "7": "9",
    "8": "1",
    "9": "2",
  };

  static encrypt(String sentence) {
    String _encryptedString = "";
    List _letters = sentence.split('');

    for (String l in _letters) {
      _encryptedString += (_encode.containsKey(l)) ? _encode[l] : l;
    }

    return _encryptedString;
  }

  static decrypt(String sentence) {
    String _decryptedString = "";
    List _letters = sentence.split('');
    Map _decode = _encode.map((k, v) => MapEntry(v, k));

    for (String l in _letters) {
      _decryptedString += (_decode.containsKey(l)) ? _decode[l] : l;
    }

    return _decryptedString;
  }
}
