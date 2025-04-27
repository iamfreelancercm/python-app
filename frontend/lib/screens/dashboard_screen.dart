import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/client.dart';
import '../widgets/account_balance_chart.dart';
import '../widgets/performance_metrics.dart';
import '../widgets/recent_activities.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Client> _clients = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      
      final clients = await _apiService.getClients();
      
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to load client data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a tablet based on the screen width
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Advisor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClients,
            tooltip: 'Refresh data',
          ),
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () {
              Navigator.pushNamed(context, '/import');
            },
            tooltip: 'Import Excel data',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Financial Advisor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Wealth Management Platform',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Clients'),
              onTap: () {
                Navigator.pop(context);
                // We're already on the dashboard which shows clients
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Import Data'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/import');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page (not implemented)
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help page (not implemented)
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isError
              ? _buildErrorWidget()
              : _buildDashboard(isTablet),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadClients,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(bool isTablet) {
    if (_clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.grey,
              size:
                  60,
            ),
            SizedBox(height: 16),
            Text(
              'No Clients Found',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 8),
            Text(
              'Import client data to get started',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/import');
              },
              child: Text('Import Data'),
            ),
          ],
        ),
      );
    }

    // Calculate summary metrics
    final totalClients = _clients.length;
    final totalAUM = _clients.fold(
        0.0, (sum, client) => sum + (client.totalAssets ?? 0.0));
    
    if (isTablet) {
      // Tablet layout - use a more complex grid
      return Column(
        children: [
          _buildSummaryCards(totalClients, totalAUM),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Client list (1/3 width)
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Clients',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Divider(),
                        Expanded(
                          child: _buildClientList(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right column - Charts and activities (2/3 width)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Top section - Performance overview
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Portfolio Overview',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Divider(),
                                Expanded(
                                  child: AccountBalanceChart(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom section - Recent activities
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Activities',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Divider(),
                                Expanded(
                                  child: RecentActivities(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Phone layout - stack vertically
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(totalClients, totalAUM),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Clients',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              height: 400,
              child: _buildClientList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Portfolio Overview',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              child: AccountBalanceChart(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              child: RecentActivities(),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSummaryCards(int totalClients, double totalAUM) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Clients',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$totalClients',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assets Under Management',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$${totalAUM.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      itemCount: _clients.length,
      itemBuilder: (context, index) {
        final client = _clients[index];
        return ListTile(
          title: Text(client.name ?? 'Unknown Client'),
          subtitle: Text('${client.segment ?? 'N/A'} - \$${client.totalAssets?.toStringAsFixed(0) ?? 'N/A'}'),
          leading: CircleAvatar(
            child: Text(
              client.name != null && client.name!.isNotEmpty
                  ? client.name![0]
                  : '?',
            ),
          ),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/client',
              arguments: client,
            );
          },
        );
      },
    );
  }
}
