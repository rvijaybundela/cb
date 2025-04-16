import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/homepage/setting/about_us_page.dart';
import 'package:untitled/homepage/setting/help_page.dart';
import 'package:untitled/homepage/nav bar/carbon_credit_calculator_page.dart'; // Optional: use if you want chart instead of table
import 'package:fl_chart/fl_chart.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/homepage/setting/settings_page.dart';
import 'package:untitled/homepage/setting/privacy_policy_page.dart';
import 'package:untitled/homepage/setting/lincese_details.dart';
import 'package:untitled/homepage/setting/walkthrough_tutorial.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _sheetData = [];
  bool _isLoading = true;
  String _selectedRange = 'Live';

  @override
  void initState() {
    super.initState();
    fetchGoogleSheetData();
  }

  Future<void> fetchGoogleSheetData() async {
    const sheetUrl = 'https://opensheet.vercel.app/1cJb2GS2jKHujHrY4W8NHyNT2CZutLcQDKqBIL0lpLjY/Sheet1';

    try {
      final response = await http.get(Uri.parse(sheetUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _sheetData = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildLiveEmissionGraph();
      case 2:
        return _buildStatsGraphs();
      case 3:
        return const Center(child: Text("Notifications", style: TextStyle(fontSize: 18)));
      case 4:
        return _buildAccountSection();
      default:
        return _buildHomeBody();
    }
  }

  Widget _buildLiveEmissionGraph() {
    List<FlSpot> coSpots = [];
    List<FlSpot> co2Spots = [];

    for (int i = 0; i < _sheetData.length; i++) {
      final entry = _sheetData[i];
      final coValue = double.tryParse(entry['CO']?.toString() ?? '');
      final co2Value = double.tryParse(entry['CO2']?.toString() ?? '');

      if (coValue != null) {
        coSpots.add(FlSpot(i.toDouble(), coValue));
      }
      if (co2Value != null) {
        co2Spots.add(FlSpot(i.toDouble(), co2Value));
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.circle, color: Colors.red, size: 12),
                  SizedBox(width: 4),
                  Text("CO", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 16),
                  Icon(Icons.circle, color: Colors.green, size: 12),
                  SizedBox(width: 4),
                  Text("CO2", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              DropdownButton<String>(
                value: _selectedRange,
                underline: Container(),
                style: const TextStyle(color: Colors.black, fontSize: 14),
                items: ['Live', 'Weekly', 'Monthly'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRange = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 400,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: coSpots,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: co2Spots,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGraphs() {
    List<BarChartGroupData> coBarGroups = [];
    List<BarChartGroupData> co2BarGroups = [];

    for (int i = 0; i < _sheetData.length; i++) {
      final entry = _sheetData[i];
      final co = double.tryParse(entry['CO'] ?? '');
      final co2 = double.tryParse(entry['CO2'] ?? '');

      if (co != null) {
        coBarGroups.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: co, color: Colors.red, width: 12),
          ],
          showingTooltipIndicators: [0], // 👈 This makes tooltip show
        ));
      }

      if (co2 != null) {
        co2BarGroups.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: co2, color: Colors.green, width: 12),
          ],
          showingTooltipIndicators: [0], // 👈 This makes tooltip show
        ));
      }
    }

    Widget buildBarChart(List<BarChartGroupData> groups, String label, Color color) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: groups,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 50,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildBarChart(coBarGroups, "CO Statistics", Colors.red),
          const SizedBox(height: 30),
          buildBarChart(co2BarGroups, "CO₂ Statistics", Colors.green),
        ],
      ),
    );
  }


  Widget _buildAccountSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/user.png'),
            ),
            SizedBox(height: 20),
            Text("vj nath", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("vjnath18@example.com", style: TextStyle(fontSize: 18)),
            Text("Vehicle ID: V001", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sheetData.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final columnKeys = _sheetData.first.keys.toList();
    final lastEntry = _sheetData.last;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0f7fa), Color(0xFFffffff)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Latest Data Card
              Card(
                color: Colors.lightBlue[50],
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text(
                        "Latest Data",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text("CO₂: ${lastEntry['MQ135'] ?? 'N/A'}"),
                      Text("CO: ${lastEntry['MQ7'] ?? 'N/A'}"),
                      Text("Time: ${lastEntry['Time'] ?? 'N/A'}"),
                    ],
                  ),
                ),
              ),
              // Reload Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  fetchGoogleSheetData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Reload Data"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
          const SizedBox(height: 20),
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
                  dataRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade50),
                  columnSpacing: 20,
                  columns: columnKeys.map((key) {
                    return DataColumn(
                      label: Text(
                        key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    );
    }).toList(),
    rows: List<DataRow>.generate(_sheetData.length, (index) {
    final row = _sheetData[index];
    return DataRow(
    cells: columnKeys.map((key) {
    return DataCell(
    Text(
    row[key]?.toString() ?? '',
    style: const TextStyle(fontSize: 13),
    ),
    );
    }).toList(),
    );
    }),
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ));
  }

  Widget _buildDrawerItem(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("vJ Nath"),
            accountEmail: const Text("vjnath18@gmail.com"),
            currentAccountPicture: const CircleAvatar(backgroundImage: AssetImage('assets/user.png')),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _buildDrawerItem(Icons.info_outline, "About Us", Colors.orange, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()));
          }),
          _buildDrawerItem(Icons.help_outline, "Help", Colors.purple, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
          }),
          _buildDrawerItem(Icons.settings, "Settings", Colors.grey, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          }),
          _buildDrawerItem(Icons.privacy_tip_outlined, "Privacy Policy", Colors.blue, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
          }),
          _buildDrawerItem(Icons.book_outlined, "License", Colors.teal, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LicensePageCustom()));
          }),
          _buildDrawerItem(Icons.school_outlined, "Walkthrough Tutorial", Colors.amber, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WalkthroughTutorialPage()));
          }),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _navigateToLogin();
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 6,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'Carbon शोधक', // Ensure this title is consistent across the app.
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.black45,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: _navigateToLogin,
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),

      drawer: _buildAppDrawer(),
      body: _getBody(),
    bottomNavigationBar: Container(
    decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 15,
    offset: Offset(0, -1),
    ),
    ],
    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
    ),
    ),
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(5, (index) {
    final iconData = [
    Icons.home_rounded,
    Icons.show_chart_rounded,
    Icons.bar_chart_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
    ][index];
    final label = ['Home', 'Live', 'Stats', 'Alerts', 'Account'][index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
    onTap: () => _onItemTapped(index),
    child: AnimatedContainer(
    duration: Duration(milliseconds: 400),
    curve: Curves.fastOutSlowIn,
    padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
    decoration: BoxDecoration(
    gradient: isSelected
    ? LinearGradient(
    colors: [Colors.blueAccent, Colors.lightBlueAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    )
        : null,
    color: isSelected ? null : Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    boxShadow: isSelected
    ? [
    BoxShadow(
    color: Colors.blueAccent.withOpacity(0.3),
    blurRadius: 12,
    offset: Offset(0, 4),
    ),
    ]
        : [],
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(iconData, color: isSelected ? Colors.white : Colors.black54),
    if (isSelected) Text(label, style: TextStyle(color: Colors.white)),
    ],
    ),
    ),
    );
    }),
    ),
    ),
    ),
    );
  }
}