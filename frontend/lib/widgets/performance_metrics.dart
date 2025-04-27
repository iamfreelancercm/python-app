import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceMetrics extends StatefulWidget {
  @override
  _PerformanceMetricsState createState() => _PerformanceMetricsState();
}

class _PerformanceMetricsState extends State<PerformanceMetrics> {
  int _touchedIndex = -1;
  
  @override
  Widget build(BuildContext context) {
    // Get the screen width to adjust display
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;
    
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
      child: isSmallScreen 
          ? Column(
              children: [
                _buildReturnsGrid(),
                SizedBox(height: 16),
                Expanded(
                  child: _buildAllocationChart(),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildReturnsGrid(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildAllocationChart(),
                ),
              ],
            ),
    );
  }

  Widget _buildReturnsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildMetricCard('YTD Return', '+8.2%', Colors.green),
        _buildMetricCard('1 Year Return', '+12.5%', Colors.green),
        _buildMetricCard('3 Year (Ann.)', '+9.7%', Colors.green),
        _buildMetricCard('Max Drawdown', '-7.3%', Colors.red),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color valueColor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Allocation',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (pieTouchResponse) {
                  setState(() {
                    if (pieTouchResponse.touchInput is FlLongPressEnd ||
                        pieTouchResponse.touchInput is FlPanEnd) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex = pieTouchResponse.touchedSectionIndex ?? -1;
                    }
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _showingSections(),
            ),
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildIndicator(Colors.blue, 'Stocks', '60%'),
            _buildIndicator(Colors.orange, 'Bonds', '25%'),
            _buildIndicator(Colors.green, 'Cash', '10%'),
            _buildIndicator(Colors.purple, 'Other', '5%'),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator(Color color, String text, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '$text: $percentage',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == _touchedIndex;
      final double fontSize = isTouched ? 20 : 16;
      final double radius = isTouched ? 60 : 50;
      
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: 60,
            title: '60%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.orange,
            value: 25,
            title: '25%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.green,
            value: 10,
            title: '10%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.purple,
            value: 5,
            title: '5%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          return PieChartSectionData();
      }
    });
  }
}
