class SignupData {
  String username = '';
  String password = '';
  String nickname = '';
  int gender = -1;
  int age = 0;
  int skinType = -1;

  SignupData();

  SignupData.fromFirestore({
    required this.username,
    required this.password,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.skinType,
  });
}
