import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:mission_comp/theme/model_theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ModelTheme>(
      builder: (context, ModelTheme themeNotifier, child) {
        return Scaffold(
            appBar: AppBar(title: const Text("Settings")),
            body: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      "Screen Settings",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w400,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Theme",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                          ),
                        ),
                        ToggleSwitch(
                          initialLabelIndex: 0,
                          totalSwitches: 2,
                          labels: const ["Light", "Dark"],
                          onToggle: (index) {
                            if (index == 0) {
                              themeNotifier.isDark = false;
                            } else {
                              themeNotifier.isDark = true;
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Unit Selection",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w400,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Altitude",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                          ),
                        ),
                        customDropdownButton(["Meters", "Feet"]),
                      ],
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  DropdownButton<String> customDropdownButton(List<String> items) {
    String dropdownValue = items[0];
    return DropdownButton(
      value: dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
    );
  }
}
