import 'dart:developer';

import 'package:financy_docs/financy_docs.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../common/constants/constants.dart';
import '../../common/utils/utils.dart';
import '../../common/widgets/widgets.dart';
import '../../locator.dart';
import '../../services/services.dart';
import 'sign_up_controller.dart';
import 'sign_up_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with CustomModalSheetMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signUpController = locator.get<SignUpController>();
  final _syncController = locator.get<SyncController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _signUpController.dispose();
    _syncController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _signUpController.addListener(_handleSignUpstateChange);
    _syncController.addListener(_handleSyncStateChange);
  }

  void _handleSignUpstateChange() {
    final state = _signUpController.state;
    switch (state.runtimeType) {
      case SignUpStateLoading:
        showDialog(
          context: context,
          builder: (context) => const CustomCircularProgressIndicator(),
        );
        break;
      case SignUpStateSuccess:
        _syncController.syncFromServer();
        break;
      case SignUpStateError:
        Navigator.pop(context);
        showCustomModalBottomSheet(
          context: context,
          content: (state as SignUpStateError).message,
          buttonText: "Tente novamente",
        );
        break;
    }
  }

  void _handleSyncStateChange() {
    switch (_syncController.state.runtimeType) {
      case DownloadedDataFromServer:
        _syncController.syncToServer();
        break;
      case UploadedDataToServer:
        Navigator.pushNamedAndRemoveUntil(
          context,
          NamedRoute.home,
          (route) => false,
        );
        break;
      case SyncStateError:
      case UploadDataToServerError:
      case DownloadDataFromServerError:
        Navigator.pop(context);
        showCustomModalBottomSheet(
          context: context,
          content: (_syncController.state as SyncStateError).message,
          buttonText: "Tente novamente",
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            NamedRoute.signUp,
            (route) => false,
          ),
        );
        break;
    }
  }

  void _onSignUpButtonPressed() {
    final valid =
        _formKey.currentState != null && _formKey.currentState!.validate();
    if (valid) {
      _signUpController.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      log("erro ao logar");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        key: Keys.signUpListView,
        children: [
          Text(
            'Gaste de maneira mais inteligente',
            textAlign: TextAlign.center,
            style: AppTextStyles.mediumText36.copyWith(
              color: AppColors.greenOne,
            ),
          ),
          Text(
            'Poupe mais',
            textAlign: TextAlign.center,
            style: AppTextStyles.mediumText36.copyWith(
              color: AppColors.greenOne,
            ),
          ),
          Image.asset(
            'assets/images/sign_up_image.png',
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  key: Keys.signUpNameField,
                  controller: _nameController,
                  labelText: "seu nome",
                  hintText: "JOHN DOE",
                  inputFormatters: [
                    UpperCaseTextInputFormatter(),
                  ],
                  validator: Validator.validateName,
                ),
                CustomTextFormField(
                  key: Keys.signUpEmailField,
                  controller: _emailController,
                  labelText: "seu e-mail",
                  hintText: "john@email.com",
                  validator: Validator.validateEmail,
                ),
                PasswordFormField(
                  key: Keys.signUpPasswordField,
                  controller: _passwordController,
                  labelText: "escolha sua senha",
                  hintText: "*********",
                  validator: Validator.validatePassword,
                  helperText:
                      "Deve ter pelo menos 8 caracteres, 1 letra maiúscula e 1 número.",
                ),
                PasswordFormField(
                  key: Keys.signUpConfirmPasswordField,
                  labelText: "confirme sua senha",
                  hintText: "*********",
                  validator: (value) => Validator.validateConfirmPassword(
                    _passwordController.text,
                    value,
                  ),
                  onEditingComplete: _onSignUpButtonPressed,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Ao se inscrever você cconcorda com nosso '),
                TextSpan(
                  text: 'Contrato',
                  style: AppTextStyles.smallText13.copyWith(
                    color: AppColors.darkGrey,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Feedback.forTap(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Agreements(),
                        ),
                      );
                    },
                ),
              ]),
              textAlign: TextAlign.center,
              style: AppTextStyles.smallText13.copyWith(
                color: AppColors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 32.0,
              right: 32.0,
              top: 16.0,
              bottom: 4.0,
            ),
            child: PrimaryButton(
              key: Keys.signUpButton,
              text: 'Inscrever-se',
              onPressed: _onSignUpButtonPressed,
            ),
          ),
          MultiTextButton(
            key: Keys.signUpAlreadyHaveAccountButton,
            onPressed: () => Navigator.popAndPushNamed(
              context,
              NamedRoute.signIn,
            ),
            children: [
              Text(
                'Já tenho uma conta? ',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.grey,
                ),
              ),
              Text(
                'Entrar ',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.greenOne,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
