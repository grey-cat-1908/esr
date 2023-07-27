import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:requests/requests.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  final Box _boxLogin = Hive.box("login");

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 150),
              Text(
                "Вход в систему",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 35),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите логин.';
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                controller: _controllerUsername,
                decoration: InputDecoration(
                  labelText: "Логин",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль.';
                  }
                  return null;
                },
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Пароль",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_outlined)
                          : const Icon(Icons.visibility_off_outlined)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        var jsonData = await _authRequest(_controllerUsername.text, _controllerPassword.text);

                        _controllerUsername.text = "";
                        _controllerPassword.text = "";

                        if (jsonData['text'] == null) {
                          CookieJar cookies = await Requests.getStoredCookies("reg.olimpiada.ru");

                          _boxLogin.put("save_time", DateTime.now());
                          _boxLogin.put("login", cookies['login']?.value);
                          _boxLogin.put("password", cookies['password']?.value);

                          GoRouter.of(context).replace('/');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(jsonData['text'])),
                          );
                        }
                      }
                    },
                    child: const Text("Войти"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();
                          _launchURL("https://reg.olimpiada.ru/login/register");
                        },
                        child: const Text("Регистрация"),
                      ),
                      const Text("|"),
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();
                          _launchURL("https://reg.olimpiada.ru/login/reset");
                        },
                        child: const Text("Забыли пароль?"),
                      ),
                    ],
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}

_launchURL(String uri) async {
  final Uri url = Uri.parse(uri);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

_authRequest(login, password) async {
  await Requests.clearStoredCookies("reg.olimpiada.ru");
  await Requests.get("https://reg.olimpiada.ru/login/cookie-setter");

  var res = await Requests.post("https://reg.olimpiada.ru/login/ajax", body: {"login": login, "password": password});
  return res.json();
}