import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/services/auth_service.dart' as AuthService;
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/views/widgets/custom_snack_bars.dart';
import 'package:quizzywizzy/views/widgets/resizer.dart';
import 'package:quizzywizzy/views/widgets/sign_in_dialog.dart';

class NavigationBar extends StatelessWidget {
  final Widget body;
  final String title;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  NavigationBar({@required this.title, @required this.body});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: WidthResizer(
                widthFactor: 0.75,
                constraintWidth: 800,
                builder: _getAppBarContent,
              ),
              centerTitle: true,
              titlePadding: EdgeInsets.all(0),
            ),
            toolbarHeight: 65,
            floating: true,
          ),
        ];
      },
      body: body,
    );
  }

  Widget _getAppBarContent(BuildContext context, BoxConstraints constraints) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (delegate.canPop()) ...[
                IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      delegate.pop();
                    }),
                Padding(padding: EdgeInsets.all(10)),
              ],
              OutlinedButton(
                child: Text("Home"),
                onPressed: () => delegate.setStack([web]),
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(
                        Colors.white.withOpacity(0.2)),
                    side:
                        MaterialStateProperty.all<BorderSide>(BorderSide.none),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
              ),
            ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _getProfile(context),
            ]),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 20,
                  letterSpacing: 0.15,
                ),
              ),
            ],
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
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.all<Color>(
                  Colors.white.withOpacity(0.2)),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white)));
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
              overlayColor: MaterialStateProperty.all<Color>(
                  Colors.white.withOpacity(0.2)),
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
}
