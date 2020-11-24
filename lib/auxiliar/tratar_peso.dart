import 'dart:math';
import 'bit_converter.dart';
import 'package:intl/intl.dart';

/**
 * Created by jeffe on 20/11/2020.
 */

class TratarPeso {
  static final String PESO_INVALIDO = "------";
  static final String FALHA_AD = "F. A/D";
  static final String SOBRECARGA = "++OL++";

  bool isPesoOk = false;
  int casasDecimais;
  double pesoLiq;
  double tara;
  double pesoBruto;
  bool isBruto;
  bool isEstavel;
  bool isFalhaAd;
  String pesoLiqFormatado;
  String taraFormatada;
  String unidade = 'kg';

  bool isSobrecarga;

  //Essa funçãoretorna true se o dado for válido
  //Formato W01 é comum a vários indicadores da Weightech como
  //WT1000, WT3000-IR, WT3000-IR-ABS, WT27-R e WT27-Gráfico.
  bool lerW01(List<int> data, int bytesToRead) {
    String strPeso;
    String strTara;
    String strBruto;
    String status;

    if (bytesToRead != 27) {
      return false;
    }

    status = new String.fromCharCodes(data, 0, 1);
    strBruto = new String.fromCharCodes(data, 2, 9);
    strTara = new String.fromCharCodes(data, 10, 17);
    strPeso = new String.fromCharCodes(data, 18, 25);

    if (status == "0") {
      isEstavel = true;
    } else {
      isEstavel = false;
    }

    if (strBruto.contains("OL")) {
      isPesoOk = false;
      isSobrecarga = true;
      return true;
    } else {
      isPesoOk = true;
      isSobrecarga = false;
    }

    try{
      pesoLiq = double.parse(strPeso);
      tara = double.parse(strTara);
      pesoBruto = double.parse(strBruto);
    }catch (e){
      return false;
    }

    if (tara == 0) {
      isBruto = true;
    } else {
      isBruto = false;
    }

    casasDecimais = determinarCasasDecimais(strPeso);

    pesoLiqFormatado = pesoLiq.toStringAsFixed(casasDecimais);
    taraFormatada = tara.toStringAsFixed(casasDecimais);

    return true;
  }

  int determinarCasasDecimais(String strPeso) {
    int intPonto = (strPeso.length - 1) - (strPeso.indexOf("."));
    if (intPonto >= strPeso.length - 1) {
      intPonto = 0;
    }
    return intPonto;
  }
}
