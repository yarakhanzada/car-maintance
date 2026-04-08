import 'package:get/get.dart';

class SignUpController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPassword() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
}
