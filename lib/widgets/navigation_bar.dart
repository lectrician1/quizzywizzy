import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/constants.dart';
import 'package:quizzywizzy/services/auth_service.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/widgets/custom_snack_bars.dart';
import 'package:quizzywizzy/widgets/sign_in_dialog.dart';

class _NavTheme {
  static Color backgroundColor = Color(0xff1b5e20);
  static Color foregroundColor = Colors.white;
  static Color hoverColor = Colors.white.withOpacity(0.2);
  static ButtonStyle leftButtonStyle = ButtonStyle(
      overlayColor: MaterialStateProperty.all<Color>(hoverColor),
      side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
      foregroundColor: MaterialStateProperty.all<Color>(foregroundColor));
  static ButtonStyle rightButtonStyle = ButtonStyle(
      side: MaterialStateProperty.all<BorderSide>(
          BorderSide(width: 0.5, color: foregroundColor)),
      overlayColor:
          MaterialStateProperty.all<Color>(hoverColor),
      foregroundColor: MaterialStateProperty.all<Color>(foregroundColor));
  static TextStyle titleStyle = TextStyle(
    color: foregroundColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
}

class NavigationBar extends StatelessWidget {
  final Widget child;
  final String title;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  NavigationBar({@required this.title, @required this.child});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: Constants.constraintWidth),
                      child: _getAppBarContent(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Divider(height: 0),
                  ),
                ],
              ),
              centerTitle: true,
              titlePadding: EdgeInsets.all(0),
            ),
            backgroundColor: _NavTheme.backgroundColor,
            shadowColor: _NavTheme.backgroundColor,
            forceElevated: true,
            elevation: 5,
            toolbarHeight: 80,
            floating: true,
            snap: true,
          ),
        ];
      },
      body: child,
    );
  }

  Widget _getAppBarContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (delegate.canPop()) ...[
                FractionallySizedBox(
                  heightFactor: 0.45,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: _NavTheme.foregroundColor,
                        hoverColor: _NavTheme.hoverColor,
                        onPressed: () {
                          delegate.pop();
                        }),
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
              ],
              FractionallySizedBox(
                heightFactor: 0.45,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: OutlinedButton(
                      child: Text("Home"),
                      onPressed: () => delegate.setStack([web]),
                      style: _NavTheme.leftButtonStyle),
                ),
              ),
            ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              FractionallySizedBox(
                heightFactor: 0.45,
                child: FittedBox(
                    fit: BoxFit.fitHeight, child: _getProfile(context)),
              ),
            ]),
          ),
          FractionallySizedBox(
            heightFactor: 0.40,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    title,
                    style: _NavTheme.titleStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProfile(BuildContext context) {
    if (delegate.isWebMode())
      return OutlinedButton(
          onPressed: () {
            delegate.setStack([app]);
          },
          child: Text("Launch App"),
          style: _NavTheme.rightButtonStyle);
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
          style: _NavTheme.rightButtonStyle);
    return PopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case "Sign Out":
              AuthService.signOutWithGoogle().catchError((e) {
                ErrorSnackBar(
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
}
