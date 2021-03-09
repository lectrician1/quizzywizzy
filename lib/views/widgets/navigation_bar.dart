import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/services/auth_service.dart' as AuthService;
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/views/widgets/custom_snack_bars.dart';
import 'package:quizzywizzy/views/widgets/sign_in_dialog.dart';

class NavigationBar extends StatelessWidget {
  final Widget _body;
  final String _title;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  NavigationBar(
      {@required String title,
      @required Widget body,
      int backButtonType = 0})
      : _body = body,
        _title = title;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _getBackButton(context),
                    ]),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _getProfile(context),
                    ]),
                  ),
                  Text(_title),
                ],
              ),
            ),
            centerTitle: true,
            floating: true,
          ),
        ];
      },
      body: _body,
    );
  }

  Widget _getProfile(BuildContext context) {
    final GoogleSignInAccount googleUser =
        Provider.of<GoogleSignInAccount>(context);
    if (googleUser == null)
      return OutlinedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => SignInDialog(),
                barrierDismissible: false);
            //AuthService.signInWithGoogle();
          },
          child: Text("Sign In"),
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.all<Color>(Colors.black),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white)));
    return PopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case "Sign Out":
              AuthService.signOutWithGoogle().catchError((e) {
                InfoSnackBar(
                    text: AuthService.getMessageFromSignOutErrorCode(e));
              });
              break;
          }
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  googleUser.displayName,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              PopupMenuItem(
                value: "Sign Out",
                child: Text("Sign Out"),
              ),
            ],
        child: GoogleUserCircleAvatar(identity: googleUser));
  }

  Widget _getBackButton(BuildContext context) {
    return delegate.canPop()
        ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              delegate.pop();
            })
        : Container();
  }
}
