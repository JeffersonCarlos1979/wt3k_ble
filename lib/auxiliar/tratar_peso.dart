import 'dart:math';
import 'package:exemplo_wtbt/constantes/wtbt.dart';
import 'bit_converter.dart';
import 'package:intl/intl.dart';

/**
 * Created by jeffe on 20/11/2020.
 */


class TratarPeso {
  static final String PESO_INVALIDO = "------";
  static final String FALHA_AD = "F. A/D";
  static final String SOBRECARGA = "++OL++";

  int imagemIndexBateria;
  bool isPesoOk = false;
  int casasDecimais;
  int nivelBateria;
  double pesoLiq;
  double tara;
  double pesoBruto;
  bool isBruto;
  bool isEstavel;
  bool isFalhaAd;
  String pesoLiqFormatado;
  String taraFormatada;
  String unidade;

  final unidades = [
    '',
    'g',
    'kg',
    't',
    'lb',
  ];




  //Essa funçãoretorna true se o dado for válido
  bool lerWtBT_BR(List<int> data) {

    if (data?.length != 15) return false;

    int nivelBateria = data[0];
    int imagemBateria;
    if (nivelBateria > 75) {
      imagemBateria = ConstantesWtbt.BATERIA_100;
    } else if (nivelBateria > 50) {
      imagemBateria = ConstantesWtbt.BATERIA_75;
    } else if (nivelBateria > 25) {
      imagemBateria = ConstantesWtbt.BATERIA_50;
    } else {
      imagemBateria = ConstantesWtbt.BATERIA_25;
    }

    int unidade = (data[1] & 0xf);
    int casasDecimais = (data[1] >> 4);

    int pesoInt = BitConverter.toInt32(data, 11);
    double peso = pesoInt * pow(10, -casasDecimais);

    int taraInt = BitConverter.toInt32(data, 7);
    double tara = taraInt * pow(10, -casasDecimais);

    bool isBruto = ((data[2] & 1) == 1);
    bool isEstavel = ((data[2] & 2) == 2);
    bool isSobrecarga = ((data[2] & 4) == 4);
    bool isFalhaAd = ((data[2] & 8) == 8);
    //bool isBrincoDisponivel = ((data[2] & 16) == 16); Esse bit indica que o WTBT-BR recebeu uma leitura de brinco transmitida pelo leitor. Vídeo: https://www.youtube.com/watch?v=dRN87ape4nA

    String pesoLiqFormatado;
    String taraFormatada;
    bool isPesoOk;

    if (isFalhaAd) {
      isPesoOk = false;
      pesoLiqFormatado = FALHA_AD;
      taraFormatada = PESO_INVALIDO;
    } else if (isSobrecarga) {
      isPesoOk = false;
      pesoLiqFormatado = SOBRECARGA;
      taraFormatada = PESO_INVALIDO;
    } else {
      isPesoOk = true;
      pesoLiqFormatado = peso.toStringAsFixed(casasDecimais);
      taraFormatada = tara.toStringAsFixed(casasDecimais);
    }


    this.casasDecimais = casasDecimais;
    this.nivelBateria = nivelBateria;
    this.imagemIndexBateria = imagemBateria;
    this.pesoLiq = peso;
    this.tara = tara;
    this.pesoBruto = peso + tara;
    this.isBruto = isBruto;
    this.isEstavel = isEstavel;
    this.isFalhaAd = isFalhaAd;
    this.unidade = unidades[unidade];
    this.isPesoOk = isPesoOk;
    this.pesoLiqFormatado = pesoLiqFormatado;
    this.taraFormatada = taraFormatada;

    return true;
  }
}


