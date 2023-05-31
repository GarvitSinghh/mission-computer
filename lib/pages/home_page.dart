import 'package:flutter/material.dart';
import 'package:mission_comp/pages/compass.dart';
import 'package:mission_comp/pages/map_screen.dart';
import 'package:mission_comp/pages/mission_plan_page.dart';
import 'package:mission_comp/pages/satellite_page.dart';
import 'package:mission_comp/pages/settings_page.dart';
import 'package:mission_comp/pages/team_page.dart';
import '../components/menu_tile.dart';

class TileItem {
  final String text;
  final Widget? nextPage;
  const TileItem({required this.text, this.nextPage});
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static List<TileItem> list = <TileItem>[
    const TileItem(nextPage: Compass(), text: "Compass"),
    const TileItem(nextPage: MapScreen(), text: "Map"),
    const TileItem(nextPage: SatellitePage(), text: "Satellite"),
    const TileItem(text: "Ground Wind"),
    const TileItem(nextPage: MissionPlanPage(), text: "Mission Plan"),
    const TileItem(nextPage: TeamPage(), text: "Team"),
    const TileItem(text: "Recovery"),
    const TileItem(nextPage: SettingsPage(), text: "Settings")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          children: List.generate(
            list.length,
            (index) => Center(
              child: MenuTile(
                text: list[index].text,
                nextPage: list[index].nextPage,
              ),
            ),
          ),
        ),
      ),
    )));
  }
}
