import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MenuTile extends StatelessWidget {
  final String text;
  final Widget? nextPage;
  const MenuTile({super.key, required this.text, this.nextPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (nextPage != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => nextPage!,
                ),
              );
            }
          },
          splashColor: Theme.of(context).splashColor,
          child: Container(
            height: MediaQuery.of(context).size.width / 2 - 30,
            width: MediaQuery.of(context).size.width / 2 - 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 7),
                SvgPicture.asset(
                  "assets/images/${text.replaceAll(' ', '')}.svg",
                  height: MediaQuery.of(context).size.width / 7,
                  color: Theme.of(context).cardColor,
                ),
                const SizedBox(height: 20),
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 17,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
