import 'package:flutter/material.dart';

class SelectionCell extends StatelessWidget {
  final String _text;
  final Function _onTap;
  final IconData _icon;
  SelectionCell({String text, IconData icon, @required Function onTap})
      : this._text = text,
        this._icon = icon,
        this._onTap = onTap;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Card(
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
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Icon(
                    _icon,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(_text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
