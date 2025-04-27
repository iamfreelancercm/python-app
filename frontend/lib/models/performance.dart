class Performance {
  final int? recordId;
  final int? accountId;
  final String? date;
  final double? value;
  final double? returnPct;
  final String? assetType;
  final double? allocationPct;

  Performance({
    this.recordId,
    this.accountId,
    this.date,
    this.value,
    this.returnPct,
    this.assetType,
    this.allocationPct,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      recordId: json['record_id'],
      accountId: json['account_id'],
      date: json['date'],
      value: json['value'] != null 
          ? double.tryParse(json['value'].toString()) ?? 0.0
          : null,
      returnPct: json['return_pct'] != null 
          ? double.tryParse(json['return_pct'].toString()) ?? 0.0
          : null,
      assetType: json['asset_type'],
      allocationPct: json['allocation_pct'] != null 
          ? double.tryParse(json['allocation_pct'].toString()) ?? 0.0
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'account_id': accountId,
      'date': date,
      'value': value,
      'return_pct': returnPct,
      'asset_type': assetType,
      'allocation_pct': allocationPct,
    };
  }
}

class PerformanceData {
  final double? ytdReturn;
  final double? oneYrReturn;
  final double? threeYrReturn;
  final double? fiveYrReturn;
  final double? volatility;
  final double? maxDrawdown;
  final Map<String, double>? allocation;

  PerformanceData({
    this.ytdReturn,
    this.oneYrReturn,
    this.threeYrReturn,
    this.fiveYrReturn,
    this.volatility,
    this.maxDrawdown,
    this.allocation,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    Map<String, double>? allocationMap;
    
    if (json['allocation'] != null) {
      allocationMap = Map<String, double>.from(
        (json['allocation'] as Map).map(
          (key, value) => MapEntry(key.toString(), double.parse(value.toString()))
        )
      );
    }
    
    return PerformanceData(
      ytdReturn: json['ytd_return'] != null ? double.tryParse(json['ytd_return'].toString()) : null,
      oneYrReturn: json['one_yr_return'] != null ? double.tryParse(json['one_yr_return'].toString()) : null,
      threeYrReturn: json['three_yr_return'] != null ? double.tryParse(json['three_yr_return'].toString()) : null,
      fiveYrReturn: json['five_yr_return'] != null ? double.tryParse(json['five_yr_return'].toString()) : null,
      volatility: json['volatility'] != null ? double.tryParse(json['volatility'].toString()) : null,
      maxDrawdown: json['max_drawdown'] != null ? double.tryParse(json['max_drawdown'].toString()) : null,
      allocation: allocationMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ytd_return': ytdReturn,
      'one_yr_return': oneYrReturn,
      'three_yr_return': threeYrReturn,
      'five_yr_return': fiveYrReturn,
      'volatility': volatility,
      'max_drawdown': maxDrawdown,
      'allocation': allocation,
    };
  }
}

class ChartData {
  final List<Map<String, dynamic>>? valueChart;
  final List<Map<String, dynamic>>? returnChart;
  final List<Map<String, dynamic>>? allocationChart;

  ChartData({
    this.valueChart,
    this.returnChart,
    this.allocationChart,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? valueChartData;
    List<Map<String, dynamic>>? returnChartData;
    List<Map<String, dynamic>>? allocationChartData;
    
    if (json['value_chart'] != null) {
      valueChartData = List<Map<String, dynamic>>.from(json['value_chart']);
    }
    
    if (json['return_chart'] != null) {
      returnChartData = List<Map<String, dynamic>>.from(json['return_chart']);
    }
    
    if (json['allocation_chart'] != null) {
      allocationChartData = List<Map<String, dynamic>>.from(json['allocation_chart']);
    }
    
    return ChartData(
      valueChart: valueChartData,
      returnChart: returnChartData,
      allocationChart: allocationChartData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value_chart': valueChart,
      'return_chart': returnChart,
      'allocation_chart': allocationChart,
    };
  }
}
