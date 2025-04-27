import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class AccountBalanceChart extends StatelessWidget {
  final List<FlSpot> mockData = List.generate(
    12,
    (index) => FlSpot(
      index.toDouble(),
      (10000 + 500 * index + (math.Random().nextDouble() * 1000 - 500)).toDouble(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Get the screen width to adjust display
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart period selection
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPeriodButton(context, '1M', true),
              SizedBox(width: 8),
              _buildPeriodButton(context, '3M', false),
              SizedBox(width: 8),
              _buildPeriodButton(context, '1Y', false),
              SizedBox(width: 8),
              _buildPeriodButton(context, 'YTD', false),
              SizedBox(width: 8),
              _buildPeriodButton(context, 'ALL', false),
            ],
          ),
          SizedBox(height: 16),
          // Balance chart
          Expanded(
            child: LineChart(
              _mainData(isSmallScreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(BuildContext context, String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Implement period selection logic
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  LineChartData _mainData(bool isSmallScreen) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 3000,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value, _) => const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          getTitles: (value) {
            // If it's a small screen, show fewer labels
            if (isSmallScreen) {
              switch (value.toInt()) {
                case 0:
                  return 'Jan';
                case 3:
                  return 'Apr';
                case 6:
                  return 'Jul';
                case 9:
                  return 'Oct';
                case 11:
                  return 'Dec';
                default:
                  return '';
              }
            } else {
              switch (value.toInt()) {
                case 0:
                  return 'Jan';
                case 1:
                  return 'Feb';
                case 2:
                  return 'Mar';
                case 3:
                  return 'Apr';
                case 4:
                  return 'May';
                case 5:
                  return 'Jun';
                case 6:
                  return 'Jul';
                case 7:
                  return 'Aug';
                case 8:
                  return 'Sep';
                case 9:
                  return 'Oct';
                case 10:
                  return 'Nov';
                case 11:
                  return 'Dec';
                default:
                  return '';
              }
            }
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value, _) => const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          getTitles: (value) {
            if (value % 3000 == 0) {
              return '\$${(value / 1000).toInt()}k';
            }
            return '';
          },
          reservedSize: 40,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 11,
      minY: 9000,
      maxY: 20000,
      lineBarsData: [
        LineChartBarData(
          spots: mockData,
          isCurved: true,
          colors: [
            Theme.of(context).primaryColor,
          ],
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).primaryColor.withOpacity(0.0),
            ],
            gradientColorStops: [0.5, 1.0],
            gradientFrom: const Offset(0, 0),
            gradientTo: const Offset(0, 1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              return LineTooltipItem(
                '\$${flSpot.y.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}
