/*import 'package:eosdart_ecc/eosdart_ecc.dart';

main() {

  EOSPrivateKey privateKey = EOSPrivateKey.fromString(
      '5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3');


  EOSPublicKey publicKey = privateKey.toEOSPublicKey();
  // Print the EOS public key
  print(publicKey.toString());


  String data = 'event_data';


  EOSSignature signature = privateKey.signString(data);
  // Print the EOS signature
  print(signature.toString());


  signature.verify(data, publicKey);
}*/