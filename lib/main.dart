import 'package:wt3k_ble/auxiliar/tratar_peso.dart';
import 'package:wt3k_ble/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'constantes/wt3k.dart';

//https://pub.dev/packages/flutter_blue

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return DeviceScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  FindDevicesScreen({Key key}) : super(key: key) {
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _startScan(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () {
                            FlutterBlue.instance.stopScan();
                            Navigator.pop(context, r.device);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search), onPressed: () => _startScan());
          }
        },
      ),
    );
  }

  _startScan() {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 10));
  }
}

class DeviceScreen extends StatelessWidget {
  final TratarPeso _tratarPeso = TratarPeso();
  BluetoothDevice device;
  BluetoothService _pesoService;
  BluetoothCharacteristic _pesoCharacteristic;
  //BluetoothCharacteristic _comandoCharacteristic;
  var _buffer = List<int>(255);//Buffer para armazenar os dados recebidos do WT3000-IR
  var _posicao = 0;//Indice do buffer

  //Notificadores que auxiliam a alterar as partes da UI correspondente aos valores e status do peso
  final _bateriaNotifier = ValueNotifier<int>(0);
  final _isBrutoNotifier = ValueNotifier<bool>(true);
  final _isEstavelNotifier = ValueNotifier<bool>(true);
  final _unidadeNotifier = ValueNotifier<String>('kg');
  final _campoPesoNotifier = ValueNotifier<String>(TratarPeso.PESO_INVALIDO);
  final _campoTaraNotifier =
      ValueNotifier<String>('Tara: ${TratarPeso.PESO_INVALIDO} kg');

  double _paddingVertical;
  double _paddinPadrao;
  double _fonteSizePeso;
  double _fonteSizeTara;

  final indicador = Indicador.WT3000_I_PRO;// Altere de acordo com o indicador.

  DeviceScreen({Key key, this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final larguraDaTela = MediaQuery.of(context).size.width;
    final alturaDaTela = MediaQuery.of(context).size.height;
    final paddingHorizontal = larguraDaTela /
        40.0; //Apenas para ajustar os widgets em relação a tamanho da tela.
    _paddingVertical = alturaDaTela / 61.6;
    _paddinPadrao = paddingHorizontal;
    _fonteSizePeso = larguraDaTela / 5.714286;
    _fonteSizeTara = larguraDaTela / 16;
    Guid _uuidPesoService;
    Guid _uuidPesoCharacteristic;

    //Seleciona o serviço e a Characterisc de acordo com o indicador.
    switch(indicador){
      case Indicador.WT3000_IR:
        _uuidPesoService = Wt3kIR.UUID_PESO_SERVICE;
        _uuidPesoCharacteristic = Wt3kIR.UUID_PESO_CHARACTERISTIC;
        break;
      case Indicador.WT3000_I_PRO:
        _uuidPesoService = Wt3kPRO.UUID_PESO_SERVICE;
        _uuidPesoCharacteristic = Wt3kPRO.UUID_PESO_CHARACTERISTIC;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Exemplo WTBT-BR"),
      ),
      body: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Informações do Peso
              Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      left: paddingHorizontal, right: paddingHorizontal),
                  height: alturaDaTela / 4,
                  color: Colors.blue,
                  child: Row(
                    //Display com todas as informações de peso
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              //Tara e bateria
                              children: [
                                Container(
                                  padding: EdgeInsets.all(_paddinPadrao),
                                  //color: Colors.green,
                                  child: ValueListenableBuilder(
                                      valueListenable: _campoTaraNotifier,
                                      builder: (BuildContext context,
                                          String campoTara, _) {
                                        return Text(
                                          //Tara
                                          campoTara,
                                          style: TextStyle(
                                            fontSize: _fonteSizeTara, //50
                                          ),
                                        );
                                      }),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(_paddinPadrao),
                                    alignment: Alignment.centerRight,
                                    //color: Colors.red,
                                    child: ValueListenableBuilder(
                                        valueListenable: _bateriaNotifier,
                                        builder: (BuildContext context,
                                            int imagemIndexBateria, _) {
                                          return SizedBox(
                                            height: 10,
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                  //Estável, peso e unidade
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      //Estável
                                      alignment: Alignment.bottomCenter,
                                      padding: EdgeInsets.only(
                                          bottom: _paddingVertical * 3,
                                          left: paddingHorizontal),
                                      //color: Colors.blue,
                                      child: ValueListenableBuilder(
                                        valueListenable: _isEstavelNotifier,
                                        builder: (BuildContext context,
                                            bool isEstavel, _) {
                                          if (isEstavel) {
                                            return Image(
                                                image: AssetImage(
                                                    'images/estavel.png'));
                                          } else {
                                            //tem que retornar algo, então vou retornar uma caixa vazia
                                            return SizedBox(
                                              height: 10,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Container(
                                        //Peso
                                        alignment: Alignment.bottomRight,
                                        padding: EdgeInsets.only(
                                            bottom: _paddingVertical * 2,
                                            right: paddingHorizontal),
                                        //color: Colors.yellow,
                                        child: ValueListenableBuilder(
                                          valueListenable: _campoPesoNotifier,
                                          builder: (BuildContext context,
                                              String campoPeso, _) {
                                            return Text(
                                              //Peso
                                              campoPeso,
                                              style: TextStyle(
                                                fontSize: _fonteSizePeso, //140
                                              ),
                                              textAlign: TextAlign.end,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                      //Unidade
                                      alignment: Alignment.bottomCenter,
                                      padding: EdgeInsets.only(
                                          bottom: _paddingVertical * 3,
                                          right: paddingHorizontal),
                                      child: ValueListenableBuilder(
                                        valueListenable: _unidadeNotifier,
                                        builder: (BuildContext context,
                                            String unidade, _) {
                                          return Text(
                                            unidade,
                                            style: TextStyle(
                                              fontSize: _fonteSizeTara, //50
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _BotoesTaraZero(),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.white,
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    _selecionarPlataforma(context);
                  },
                  child: Text('Selecionar plataforma',
                    style: TextStyle(fontSize: _fonteSizeTara),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  void _selecionarPlataforma(BuildContext context) async {
    await _pesoCharacteristic?.setNotifyValue(false);
    device?.disconnect();

    device = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FindDevicesScreen()),
    );
    print('Device ${device?.name}');

    if (device == null) return;

    _conectar();
  }

  Future<void> _conectar() async {
    await device.connect();

    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      if (service.uuid == Wt3kIR.UUID_PESO_SERVICE) {
        _pesoService = service;
      }
    });

    // Reads all characteristics
    for (BluetoothCharacteristic c in _pesoService.characteristics) {
      if (c.uuid == Wt3kIR.UUID_PESO_CHARACTERISTIC) {
        _pesoCharacteristic = c;
      }
    }

    await _pesoCharacteristic.setNotifyValue(true);
    _pesoCharacteristic.value.listen((data) {
      bool isPodeTratar = false;

      data?.forEach((b) {
        if (_posicao >= _buffer.length) _posicao = 0;
        _buffer[_posicao++] = b;

        if (_posicao > 1) {
          if ((_buffer[_posicao - 2]) == 13 && (_buffer[_posicao - 1]) == 10) {


            /*
                  * Quando encontra a sequencia [CR][LF] no buffer, ele envia para a rotina de tratamento.
                  * Essa rotina vai validar e extrair as informações de peso.
                  * Se por exemplo, o buffer não tiver o tamanho esperado (27 no caso do WT3000-I-R), ele é descartado.
                  * */

            if (_tratarPeso.lerW01(_buffer, _posicao)) {
              /*
                Modificar os campos ValueNotifiers faz com que os Widgets ValueListenableBuilder associados
                se modifiquem automaticamente com os novos valores.
              */

              _bateriaNotifier.value = 0;
              _isBrutoNotifier.value = _tratarPeso.isBruto;
              _isEstavelNotifier.value = _tratarPeso.isEstavel;
              _unidadeNotifier.value = _tratarPeso.unidade;
              _campoPesoNotifier.value = _tratarPeso.pesoLiqFormatado;
              _campoTaraNotifier.value =
              "Tara: ${_tratarPeso.taraFormatada} ${_tratarPeso.unidade}";
            }

            _posicao = 0;
          }
        }

      });

    });
  }

  Future<void> _tarar() async {
    _enviarComando("${Comandos.TARAR}");
  }

  Future<void> _zerar() async {
    _enviarComando("${Comandos.ZERAR}");
  }

  Future<void> _enviarComando(String commandData) async {
    var buff = commandData.codeUnits;

    try {
      _pesoCharacteristic.write(buff);
    } catch (e) {
      print(e);
    }
  }

  Widget _BotoesTaraZero() {
    /*
    Só exibe os botões se for o WT3000-IR pois, o WT3000-I-Pro não aceita comandos.
     */
    if(indicador == Indicador.WT3000_I_PRO){
      return SizedBox(
        height: 10,
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: FlatButton(
            child: Text(
              "Tarar",
              style: TextStyle(fontSize: _fonteSizeTara),
            ),
            onPressed: () {
              _tarar();
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: FlatButton(
            child: Text(
              "Zerar",
              style: TextStyle(fontSize: _fonteSizeTara),
            ),
            onPressed: () {
              _zerar();
            },
          ),
        ),
      ],
    );
  }
}

