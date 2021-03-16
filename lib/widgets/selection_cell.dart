import 'package:flutter/material.dart';

class SelectionCell extends StatelessWidget {
  final String _text;
  final Function _onTap;
  final IconData _icon;
  final double width;
  final double height;
  SelectionCell({@required String text, @required IconData icon, this.width=200, this.height=200, @required Function onTap})
      : this._text = text,
        this._icon = icon,
        this._onTap = onTap;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Container(
      width: width,
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Material(
          color: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: InkWell(
            splashColor: Colors.blue,
            onTap: _onTap,
            child: Stack(
              children: [
                Container(
                  width: width,
                  height: height * 3/4,
                  child: Center(
                    child: Icon(
                      _icon,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_text,
                    textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
