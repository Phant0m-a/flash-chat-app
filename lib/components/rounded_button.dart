import 'package:flutter/material.dart';

// Rounded button
// Takes IN COLOR, ONTAP function, TEXT and give out a button
class RoundedButton extends StatelessWidget {
  RoundedButton({@required this.color, this.onTap, @required this.text});
  final String text;
  final Function onTap;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: onTap,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
