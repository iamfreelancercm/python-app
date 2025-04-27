import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/activity.dart';
import '../services/api_service.dart';
import '../widgets/account_balance_chart.dart';
import '../widgets/performance_metrics.dart';
import '../widgets/recent_activities.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ApiService _apiService = ApiService();
  List<Activity> _activities = [];
  Map<String, dynamic> _performance = {};
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // We'll load data in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    final Account account = ModalRoute.of(context)!.settings.arguments as Account;
    
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      
      // Load activities and performance in parallel
      final activitiesFuture = _apiService.getAccountActivities(account.id ?? 0);
      final performanceFuture = _apiService.getAccountPerformance(account.id ?? 0);
      
      final activities = await activitiesFuture;
      final performance = await performanceFuture;
      
      setState(() {
        _activities = activities;
        _performance = performance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to load account data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Account account = ModalRoute.of(context)!.settings.arguments as Account;
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isError
              ? _buildErrorWidget()
              : _buildAccountDetails(account, isTablet),
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
            onPressed: _loadAccountData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails(Account account, bool isTablet) {
    return isTablet ? _buildTabletLayout(account) : _buildPhoneLayout(account);
  }

  Widget _buildTabletLayout(Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccountHeader(account),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Account info and activities (1/3 width)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Account information card
                    Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Divider(),
                            _buildAccountInfo(account),
                          ],
                        ),
                      ),
                    ),
                    // Activities list
                    Expanded(
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
                                child: _buildActivitiesList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right column - Charts and metrics (2/3 width)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Top section - Account balance chart
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
                                'Account Balance History',
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
                    // Bottom section - Performance metrics
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
                                'Performance Metrics',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Divider(),
                              Expanded(
                                child: _buildPerformanceGrid(),
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
  }

  Widget _buildPhoneLayout(Account account) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountHeader(account),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Information',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Divider(),
                  _buildAccountInfo(account),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          _buildPerformanceGrid(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Account Balance History',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            height: 250,
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
            padding: EdgeInsets.all(8),
            child: _buildActivitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountHeader(Account account) {
    String accountIcon;
    switch (account.accountType?.toLowerCase() ?? '') {
      case 'ira':
        accountIcon = 'I';
        break;
      case 'roth ira':
        accountIcon = 'R';
        break;
      case '401(k)':
      case '401(k) rollover':
        accountIcon = '4';
        break;
      case 'trust':
        accountIcon = 'T';
        break;
      default:
        accountIcon = 'A';
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              accountIcon,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.accountType ?? 'Unknown Account',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 4),
                Text(
                  'Account #: ${account.id ?? 'N/A'}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(height: 4),
                Text(
                  'Balance: \$${account.currentBalance?.toStringAsFixed(0) ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(Account account) {
    return Column(
      children: [
        _buildInfoRow('Account Type', account.accountType ?? 'N/A'),
        _buildInfoRow('Opening Date', account.openingDate ?? 'N/A'),
        _buildInfoRow('Current Balance', '\$${account.currentBalance?.toStringAsFixed(0) ?? 'N/A'}'),
        _buildInfoRow('Currency', account.currency ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    if (_activities.isEmpty) {
      return Center(
        child: Text('No recent activities found'),
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
            ),
          ),
          title: Text(activity.description ?? 'Unknown Activity'),
          subtitle: Text(activity.date ?? 'Unknown Date'),
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

  Widget _buildPerformanceGrid() {
    if (_performance.isEmpty) {
      return Center(
        child: Text('No performance data available'),
      );
    }
    
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      padding: EdgeInsets.all(10),
      children: [
        _buildPerformanceCard(
          'YTD Return',
          '${_performance['ytd_return'] ?? 0}%',
          (_performance['ytd_return'] ?? 0) >= 0 ? Colors.green : Colors.red,
        ),
        _buildPerformanceCard(
          '1 Year Return',
          '${_performance['one_yr_return'] ?? 0}%',
          (_performance['one_yr_return'] ?? 0) >= 0 ? Colors.green : Colors.red,
        ),
        _buildPerformanceCard(
          '3 Year Return (Ann.)',
          '${_performance['three_yr_return'] ?? 0}%',
          (_performance['three_yr_return'] ?? 0) >= 0 ? Colors.green : Colors.red,
        ),
        _buildPerformanceCard(
          '5 Year Return (Ann.)',
          '${_performance['five_yr_return'] ?? 0}%',
          (_performance['five_yr_return'] ?? 0) >= 0 ? Colors.green : Colors.red,
        ),
        _buildPerformanceCard(
          'Volatility',
          '${_performance['volatility'] ?? 0}%',
          Colors.blue,
        ),
        _buildPerformanceCard(
          'Max Drawdown',
          '${_performance['max_drawdown'] ?? 0}%',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(String title, String value, Color valueColor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
