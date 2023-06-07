import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Indicador {
  /*
    Para saber a diferença visual entre o WT3000-IR e o WT3000-PRO, é só visitar a página dos indicadores:
     */
  static const int wt3000Ir =
      0; //https://www.weightech.com.br/detalhes.asp?id=502013&n=WT3000-iR;
  static const int wt3000iPro =
      1; //https://www.weightech.com.br/detalhes.asp?id=501750&n=WT3000-i-PRO
}

class Wt3kIR {
  //Serviços
  static const String atPesoService = "0000E711-0000-1000-8000-00805f9b34fb";
  //Characteristcs
  static const String atPesoCharacteristic =
      "0000E813-0000-1000-8000-00805f9b34fb";
  //Guid serviços
  static final Guid uuidPesoService = Guid(atPesoService);
  //Guid characteristics
  static final Guid uuidPesoCharacteristic = Guid(atPesoCharacteristic);
}

class Wt3kPRO {
  //Serviços
  static const String atPesoService = "0000FFE0-0000-1000-8000-00805f9b34fb";
  //Characteristcs
  static const String atPesoCharacteristic =
      "0000FFE1-0000-1000-8000-00805f9b34fb";
  //Guid serviços
  static final Guid uuidPesoService = Guid(atPesoService);
  //Guid characteristics
  static final Guid uuidPesoCharacteristic = Guid(atPesoCharacteristic);
}

class Comandos {
  static String zerar = "MZ\r\n";
  static String tarar = "MT\r\n";
}
