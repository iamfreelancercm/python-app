import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/account.dart';
import '../services/api_service.dart';
import '../widgets/account_balance_chart.dart';
import '../widgets/performance_metrics.dart';

class ClientDetailsScreen extends StatefulWidget {
  @override
  _ClientDetailsScreenState createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final ApiService _apiService = ApiService();
  List<Account> _accounts = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // We'll fetch accounts in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final Client client = ModalRoute.of(context)!.settings.arguments as Client;
    
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      
      final accounts = await _apiService.getClientAccounts(client.id ?? 0);
      
      setState(() {
        _accounts = accounts;
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
    final Client client = ModalRoute.of(context)!.settings.arguments as Client;
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isError
              ? _buildErrorWidget()
              : _buildClientDetails(client, isTablet),
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
            onPressed: _loadAccounts,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetails(Client client, bool isTablet) {
    return isTablet ? _buildTabletLayout(client) : _buildPhoneLayout(client);
  }

  Widget _buildTabletLayout(Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClientHeader(client),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Client info and accounts (1/3 width)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Client information card
                    Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Client Information',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Divider(),
                            _buildClientInfo(client),
                          ],
                        ),
                      ),
                    ),
                    // Accounts list
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Accounts',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Divider(),
                              Expanded(
                                child: _buildAccountsList(),
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
                                child: PerformanceMetrics(),
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

  Widget _buildPhoneLayout(Client client) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClientHeader(client),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client Information',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Divider(),
                  _buildClientInfo(client),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Accounts',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            height: 200,
            child: _buildAccountsList(),
          ),
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
              'Performance Metrics',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            height: 250,
            padding: EdgeInsets.all(16),
            child: PerformanceMetrics(),
          ),
        ],
      ),
    );
  }

  Widget _buildClientHeader(Client client) {
    // Calculate total client assets
    double totalAssets = _accounts.fold(
        0.0, (sum, account) => sum + (account.currentBalance ?? 0.0));
    
    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              client.name != null && client.name!.isNotEmpty
                  ? client.name![0]
                  : '?',
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
                  client.name ?? 'Unknown Client',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 4),
                Text(
                  client.segment ?? 'N/A',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(height: 4),
                Text(
                  'Total Assets: \$${totalAssets.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(Client client) {
    return Column(
      children: [
        _buildInfoRow('Email', client.email ?? 'N/A'),
        _buildInfoRow('Phone', client.phone ?? 'N/A'),
        _buildInfoRow('Birth Date', client.birthDate ?? 'N/A'),
        _buildInfoRow('Risk Profile', client.riskProfile ?? 'N/A'),
        _buildInfoRow('Segment', client.segment ?? 'N/A'),
        _buildInfoRow('Total Assets', '\$${client.totalAssets?.toStringAsFixed(0) ?? 'N/A'}'),
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

  Widget _buildAccountsList() {
    if (_accounts.isEmpty) {
      return Center(
        child: Text('No accounts found for this client'),
      );
    }
    
    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final account = _accounts[index];
        return ListTile(
          title: Text(account.accountType ?? 'Unknown Account'),
          subtitle: Text('Balance: \$${account.currentBalance?.toStringAsFixed(0) ?? 'N/A'}'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/account',
              arguments: account,
            );
          },
        );
      },
    );
  }
}
