class TratarPeso {
  static const String pesoInvalido = "------";
  static const String falhaAd = "F. A/D";
  static const String sobrecarga = "++OL++";

  bool isPesoOk = false;
  int casasDecimais = 0;
  double pesoLiq = 0.0;
  double tara = 0.0;
  double pesoBruto = 0.0;
  bool isBruto = false;
  bool isEstavel = false;
  bool isFalhaAd = false;
  String pesoLiqFormatado = pesoInvalido;
  String taraFormatada = pesoInvalido;
  String unidade = 'kg';

  bool isSobrecarga = false;

  //Essa funçãoretorna true se o dado for válido
  //Formato W01 é comum a vários indicadores da Weightech como
  //WT1000, WT3000-IR, WT3000-IR-ABS, WT27-R e WT27-Gráfico.
  bool lerW01(List<int> data, int bytesToRead) {
    String strPeso;
    String strTara;
    String strBruto;
    String status;

    //WT3000-IR transmite 27 bytes
    //WT3000-I-PRO transmite 47 bytes
    if (bytesToRead != 27 && bytesToRead != 47) {
      return false;
    }

    status = String.fromCharCodes(data, 0, 1);
    strBruto = String.fromCharCodes(data, 2, 9).replaceAll(",", ".");
    strTara = String.fromCharCodes(data, 10, 17).replaceAll(",", ".");
    strPeso = String.fromCharCodes(data, 18, 25).replaceAll(",", ".");

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

    try {
      pesoLiq = double.parse(strPeso);
      tara = double.parse(strTara);
      pesoBruto = double.parse(strBruto);
    } catch (e) {
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
