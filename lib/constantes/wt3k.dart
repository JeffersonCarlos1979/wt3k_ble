
import 'package:flutter_blue/flutter_blue.dart';

class Indicador{
    /*
    Para saber a diferença visual entre o WT3000-IR e o WT3000-PRO, é só visitar a página dos indicadores:
     */
    static const int WT3000_IR = 0; //https://www.weightech.com.br/detalhes.asp?id=502013&n=WT3000-iR;
    static const int WT3000_I_PRO = 1; //https://www.weightech.com.br/detalhes.asp?id=501750&n=WT3000-i-PRO
}

class Wt3kIR {
    //Serviços
    static const String AT_PESO_SERVICE = "0000E711-0000-1000-8000-00805f9b34fb";
    //Characteristcs
    static const String AT_PESO_CHARACTERISTIC = "0000E813-0000-1000-8000-00805f9b34fb";
    //Guid serviços
    static final Guid UUID_PESO_SERVICE = Guid(AT_PESO_SERVICE);
    //Guid characteristics
    static final Guid UUID_PESO_CHARACTERISTIC = Guid(AT_PESO_CHARACTERISTIC);
}

class Wt3kPRO {
    //Serviços
    static const String AT_PESO_SERVICE = "0000FFE0-0000-1000-8000-00805f9b34fb";
    //Characteristcs
    static const String AT_PESO_CHARACTERISTIC = "0000FFE1-0000-1000-8000-00805f9b34fb";
    //Guid serviços
    static final Guid UUID_PESO_SERVICE = Guid(AT_PESO_SERVICE);
    //Guid characteristics
    static final Guid UUID_PESO_CHARACTERISTIC = Guid(AT_PESO_CHARACTERISTIC);
}

class Comandos{
    static String ZERAR = "MZ\r\n";
    static String TARAR = "MT\r\n";
}


