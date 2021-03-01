import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/views/widgets/custom_snack_bars.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:quizzywizzy/services/auth_service.dart' as AuthService;
import 'package:quizzywizzy/constants.dart' as Constants;

class SignInDialog extends StatefulWidget {
  @override
  _SignInDialogState createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: SignInDialogDomain());
  }
}

class SignInDialogDomain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInDialogWindow(
        top: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Spacer(flex: 1),
                  Expanded(
                    child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text("Sign In to ${Constants.title}")),
                    flex: 2,
                  ),
                  Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Spacer(flex: 1),
            Expanded(
              flex: 5,
              child: FadeInImage.memoryNetwork(
                  fit: BoxFit.fitHeight,
                  placeholder: kTransparentImage,
                  image: "assets/images/naperville203.png"),
            ),
            Spacer(flex: 1),
            Expanded(
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  "Sign in with your\nNaperville 203\nGoogle account",
                  textAlign: TextAlign.center,
                ),
              ),
              flex: 7,
            ),
            Expanded(
              child: Center(
                child: Text(
                  "I have a whitelisted email | Privacy Policy",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              flex: 3,
            ),
          ],
        ));
  }
}

class SignInDialogWindow extends StatelessWidget {
  final Widget top;
  final Widget body;
  SignInDialogWindow({@required this.top, @required this.body});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ChangeNotifierProvider<SignInButtonModel>.value(
          value: SignInButtonModel(),
          child: Consumer<SignInButtonModel>(
            builder: (context, provider, child) => Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[150],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -3,
                          right: -3,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: !provider.isLoading
                                ? IconButton(
                                    icon: Icon(Icons.cancel,
                                        color: Colors.blueGrey[800]),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                : Image.memory(kTransparentImage),
                          ),
                        ),
                        top,
                      ],
                    ),
                  ),
                  flex: 1,
                ),
                Divider(height: 10),
                Expanded(
                  flex: 4,
                  child: body,
                ),
                Expanded(
                  child: Ink(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12)),
                      ),
                      child: SignInDialogButton()),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInDialogButton extends StatefulWidget {
  @override
  _SignInDialogButtonState createState() => _SignInDialogButtonState();
}

class _SignInDialogButtonState extends State<SignInDialogButton>
    with TickerProviderStateMixin {
  AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _anim.repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SignInButtonModel provider = Provider.of<SignInButtonModel>(context);
    return provider.isLoading
        ? SignInButtonTemplate(
            body: CircularProgressIndicator(
              valueColor: _anim.drive(
                  ColorTween(begin: Colors.greenAccent, end: Colors.red)),
            ),
          )
        : InkWell(
            onTap: () {
              provider.isLoading = true;
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(
                        "Signing in through Google Sign In OAuth consent screen..."),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3)));
              AuthService.signInWithGoogle().then((user) {
                provider.isLoading = false;
                Navigator.of(context).pop();
              }).catchError((e) {
                provider.isLoading = false;
                print(e.code);
                print(e.message);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(InfoSnackBar(text: "Unable to complete sign in process: ${AuthService.getMessageFromGoogleSignInErrorCode(e)}"));
              });
            },
            child: SignInButtonTemplate(
              body: Text("Sign In",
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          );
  }
}

class SignInButtonTemplate extends StatelessWidget {
  final Widget body;
  SignInButtonTemplate({@required this.body});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(flex: 1),
        Expanded(
          child: FittedBox(fit: BoxFit.fitHeight, child: body),
          flex: 2,
        ),
        Spacer(flex: 1),
      ],
    );
  }
}

class SignInButtonModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
