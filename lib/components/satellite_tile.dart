import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SatelliteTile extends StatelessWidget {
  final String satName;
  final bool active;
  const SatelliteTile({super.key, required this.satName, this.active=false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? Theme.of(context).unselectedWidgetColor : Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      width: MediaQuery.of(context).size.width - 50,
      height: 50,
      child: Row(children: [
        const SizedBox(width: 20),
        SvgPicture.asset("assets/images/satellite-tile.svg", color: active ? Theme.of(context).primaryColorDark : Theme.of(context).cardColor),
        const SizedBox(width: 30),
        Text(
          satName,
          style: TextStyle(
            color: active ? Theme.of(context).primaryColorDark : null,
              fontFamily: "Poppins", fontWeight: FontWeight.w400),
        )
      ]),
    );
  }
}
