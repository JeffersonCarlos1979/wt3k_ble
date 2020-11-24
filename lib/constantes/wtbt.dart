
import 'package:flutter_blue/flutter_blue.dart';

class ConstantesWtbt {
    static String teste = "teste";
    //Serviços
    static String CLIENT_CHARACTERISTIC_CONFIG = "00002902-0000-1000-8000-00805f9b34fb";
    static final String AT_WTBT_SERVICE = "0000181D-0000-1000-8000-00805f9b34fb";
    static final String AT_DEVICE_INFORMATION_SERVICE = "0000180A-0000-1000-8000-00805f9b34fb";
    //Characteristcs
    static final String AT_CHAR_COMANDO = "00002B26-0000-1000-8000-00805f9b34fb";
    static final String AT_CHAR_STATUS = "00002b21-0000-1000-8000-00805f9b34fb";
    static final String AT_CHAR_PESO = "00002A98-0000-1000-8000-00805f9b34fb";
    static final String AT_CHAR_SOFTWARE_REVISION = "00002A28-0000-1000-8000-00805f9b34fb";
    //Guid serviços
    static final Guid UUID_WTBT_SERVICE_SERIVCE = Guid(AT_WTBT_SERVICE);
    static final Guid UUID_DEVICE_INFORMATION_SERIVCE = Guid(AT_DEVICE_INFORMATION_SERVICE);
    //Guid characteristics
    static final Guid UUID_CHAR_COMANDO = Guid(AT_CHAR_COMANDO);
    static final Guid UUID_CHAR_STATUS = Guid(AT_CHAR_STATUS);
    static final Guid UUID_CHAR_PESO = Guid(AT_CHAR_PESO);
    static final Guid UUID_CHAR_SOFTWARE_REVISION = Guid(AT_CHAR_SOFTWARE_REVISION);
    //Bateria
    static final int BATERIA_SEM_STATUS = -1;
    static final int BATERIA_25 = 0;
    static final int BATERIA_50 = 1;
    static final int BATERIA_75 = 2;
    static final int BATERIA_100 = 3;
}

class Comandos{
    static String ZERAR = "CDL";
    static String TARAR = "TAR";
}

