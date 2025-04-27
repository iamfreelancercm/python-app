import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/api_service.dart';

class RecentActivities extends StatefulWidget {
  final int? accountId;
  
  RecentActivities({this.accountId});
  
  @override
  _RecentActivitiesState createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities> {
  final ApiService _apiService = ApiService();
  List<Activity> _activities = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      List<Activity> activities;
      
      if (widget.accountId != null) {
        // Load activities for a specific account
        activities = await _apiService.getAccountActivities(widget.accountId!);
      } else {
        // Load recent activities across all accounts (for dashboard)
        activities = await _apiService.getRecentActivities();
      }
      
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to load activities: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading activities',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _loadActivities,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              color: Colors.grey,
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              'No activities found',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        
        // Determine icon and color based on activity type
        IconData icon;
        Color color;
        
        switch (activity.type?.toLowerCase() ?? '') {
          case 'deposit':
            icon = Icons.arrow_downward;
            color = Colors.green;
            break;
          case 'withdrawal':
            icon = Icons.arrow_upward;
            color = Colors.red;
            break;
          case 'buy':
            icon = Icons.shopping_cart;
            color = Colors.blue;
            break;
          case 'sell':
            icon = Icons.attach_money;
            color = Colors.orange;
            break;
          case 'dividend':
            icon = Icons.monetization_on;
            color = Colors.green;
            break;
          case 'transfer in':
            icon = Icons.transit_enterexit;
            color = Colors.purple;
            break;
          case 'transfer out':
            icon = Icons.exit_to_app;
            color = Colors.red;
            break;
          case 'fee':
            icon = Icons.payment;
            color = Colors.red;
            break;
          default:
            icon = Icons.swap_horiz;
            color = Colors.grey;
        }
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            activity.description ?? 'Unknown Activity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            activity.date ?? 'Unknown Date',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          trailing: Text(
            '\$${activity.amount?.toStringAsFixed(0) ?? 'N/A'}',
            style: TextStyle(
              color: (activity.amount ?? 0) >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
