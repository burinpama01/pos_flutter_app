import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posflutterapp/bloc/authentication/authentication_bloc.dart';
import 'package:posflutterapp/bloc/login/login_bloc.dart';
import 'package:posflutterapp/widgets/ForgotButton.dart';
import 'package:posflutterapp/widgets/create_account_button.dart';
import 'package:posflutterapp/widgets/login_botton.dart';

import '../user_repository.dart';

class LoginForm extends StatefulWidget {
  final UserRepository _userRepository;

  LoginForm({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginBloc _loginBloc;

  UserRepository get _userRepository => widget._userRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onLoginEmailChanged);
    _passwordController.addListener(_onLoginPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('เข้าสู่ระบบ ล้มเหลว',style: GoogleFonts.itim(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.red)), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('กำลังเข้าสู่ระบบ...',style: GoogleFonts.itim(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white)),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context)
              .add(AuthenticationLoggedIn());
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.purple,
                          size: 100,
                        ), // icon
                        Text(
                          "POS SHOP",
                          style: TextStyle(
                              color: Colors.purple,
                              fontSize: 45,
                              fontWeight: FontWeight.bold),
                        ), // text
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    cursorColor: Colors.purple,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: Colors.purple,
                      ),
                      labelText: 'อีเมล',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isEmailValid ? 'ข้อมูลไม่ถูกต้อง กรุณากรอกข้อมูล' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.purple,
                      ),
                      labelText: 'รหัสผ่าน',
                    ),
                    obscureText: true,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isPasswordValid ? 'กรุณากรอกข้อมูล' : null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        LoginButton(
                          onPressed: isLoginButtonEnabled(state)
                              ? _onFormSubmitted
                              : null,
                        ),
//                        ForgotButton(userRepository: _userRepository),
//                        GoogleLoginButton(),
                        CreateAccountButton(userRepository: _userRepository),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginEmailChanged() {
    _loginBloc.add(
      LoginEmailChanged(email: _emailController.text),
    );
  }

  void _onLoginPasswordChanged() {
    _loginBloc.add(
      LoginPasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginWithCredentialsPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
