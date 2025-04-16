import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveEmissionGraph extends StatefulWidget {
  const LiveEmissionGraph({super.key});

  @override
  State<LiveEmissionGraph> createState() => _LiveEmissionGraphState();
}

class _LiveEmissionGraphState extends State<LiveEmissionGraph> {
  List<Map<String, dynamic>> _sheetData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;
  String _selectedRange = 'All';

  final List<String> _rangeOptions = ['All', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    fetchGoogleSheetData();
  }

  Future<void> fetchGoogleSheetData() async {
    const sheetUrl =
        'https://opensheet.vercel.app/1cJb2GS2jKHujHrY4W8NHyNT2CZutLcQDKqBIL0lpLjY/Sheet1';

    try {
      final response = await http.get(Uri.parse(sheetUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _sheetData = data.map((e) => e as Map<String, dynamic>).toList();
          _filteredData = _sheetData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error: $e');
    }
  }

  void _filterDataBasedOnRange() {
    if (_selectedRange == 'Weekly') {
      _filteredData = _sheetData.take(7).toList();
    } else if (_selectedRange == 'Monthly') {
      _filteredData = _sheetData.take(30).toList();
    } else {
      _filteredData = _sheetData;
    }
  }

  List<FlSpot> _extractSpots(String key) {
    List<FlSpot> spots = [];
    for (int i = 0; i < _filteredData.length; i++) {
      final val = double.tryParse(_filteredData[i][key]?.toString() ?? '');
      if (val != null) spots.add(FlSpot(i.toDouble(), val));
    }
    return spots;
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildGraphCard() {
    final co2Spots = _extractSpots('CO2');
    final coSpots = _extractSpots('CO');

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                dropdownColor: Colors.grey[900],
                value: _selectedRange,
                underline: Container(),
                style: const TextStyle(color: Colors.white),
                items: _rangeOptions.map((range) {
                  return DropdownMenuItem(
                    value: range,
                    child: Text(range),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRange = value!;
                    _filterDataBasedOnRange();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.transparent,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          );
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
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.grey.shade900,
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final gas = spot.bar.color == Colors.red
                              ? "CO2"
                              : spot.bar.color == Colors.green
                              ? "CO"
                              : "Gas";
                          return LineTooltipItem(
                            '$gas: ${spot.y.toStringAsFixed(1)}\n',
                            TextStyle(
                              color: spot.bar.color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: co2Spots,
                      isCurved: true,
                      color: Colors.red,
                      dotData: FlDotData(show: false),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.15),
                      ),
                    ),
                    LineChartBarData(
                      spots: coSpots,
                      isCurved: true,
                      color: Colors.green,
                      dotData: FlDotData(show: false),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend("CO2", Colors.red),
                _buildLegend("CO", Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF23293A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Live Emission Graph'),
          backgroundColor: Colors.green.shade700,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _filteredData.isEmpty
            ? const Center(child: Text("No data available", style: TextStyle(color: Colors.white)))
            : _buildGraphCard(),
      ),
    );
  }
}
