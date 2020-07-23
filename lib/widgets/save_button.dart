import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback _onPressed;

  SaveButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: Text(
        'บันทึก',
      ),
      color: Colors.orange,
    );
  }
}