import pandas as pd
import numpy as np
from datetime import datetime, timedelta

def process_client_data(client_df):
    """
    Process client data for dashboard display
    
    Args:
        client_df: DataFrame containing client information
        
    Returns:
        Dictionary with processed client information
    """
    if client_df.empty:
        return {"error": "No client data available"}
    
    # Calculate number of clients
    client_count = len(client_df)
    
    # Calculate total assets under management
    total_aum = client_df['total_assets'].sum() if 'total_assets' in client_df.columns else 0
    
    # Calculate average client age
    avg_age = 0
    if 'birth_date' in client_df.columns:
        client_df['age'] = (datetime.now() - pd.to_datetime(client_df['birth_date'])).dt.days / 365.25
        avg_age = client_df['age'].mean()
    
    # Calculate client distribution by segment
    segment_distribution = {}
    if 'segment' in client_df.columns:
        segment_counts = client_df['segment'].value_counts().to_dict()
        total_clients = sum(segment_counts.values())
        segment_distribution = {segment: {"count": count, "percentage": (count/total_clients)*100} 
                              for segment, count in segment_counts.items()}
    
    return {
        "client_count": client_count,
        "total_aum": total_aum,
        "avg_age": avg_age,
        "segment_distribution": segment_distribution
    }

def process_account_performance(performance_df):
    """
    Calculate performance metrics for an account
    
    Args:
        performance_df: DataFrame containing performance data
        
    Returns:
        Dictionary with calculated metrics
    """
    if performance_df.empty:
        return {"error": "No performance data available"}
    
    # Filter out rows with missing values for date
    performance_df = performance_df.dropna(subset=['date'])
    
    # Set default values
    ytd_return = 0.0
    one_yr_return = 0.0
    three_yr_return = 0.0
    five_yr_return = 0.0
    volatility = 0.0
    max_drawdown = 0.0
    allocation = {"Stocks": 60, "Bonds": 30, "Cash": 10}  # Default allocation if none found
    
    # Sort by date
    if 'date' in performance_df.columns:
        performance_df['date'] = pd.to_datetime(performance_df['date'])
        performance_df = performance_df.sort_values('date')
    
    # Calculate return metrics if return_pct is available
    if 'return_pct' in performance_df.columns:
        # Drop any NaN values for return_pct
        return_df = performance_df.dropna(subset=['return_pct'])
        
        if not return_df.empty:
            current_date = datetime.now()
            
            # YTD calculation
            ytd_start = datetime(current_date.year, 1, 1)
            ytd_data = return_df[return_df['date'] >= ytd_start]
            if not ytd_data.empty:
                ytd_return = ytd_data['return_pct'].sum()
            
            # 1 year calculation
            one_yr_ago = current_date - timedelta(days=365)
            one_yr_data = return_df[return_df['date'] >= one_yr_ago]
            if not one_yr_data.empty:
                one_yr_return = one_yr_data['return_pct'].sum()
            
            # 3 year calculation (annualized)
            three_yr_ago = current_date - timedelta(days=365*3)
            three_yr_data = return_df[return_df['date'] >= three_yr_ago]
            if not three_yr_data.empty and len(three_yr_data) > 3:
                three_yr_return = ((1 + three_yr_data['return_pct'].sum()/100) ** (1/3) - 1) * 100
            
            # 5 year calculation (annualized)
            five_yr_ago = current_date - timedelta(days=365*5)
            five_yr_data = return_df[return_df['date'] >= five_yr_ago]
            if not five_yr_data.empty and len(five_yr_data) > 5:
                five_yr_return = ((1 + five_yr_data['return_pct'].sum()/100) ** (1/5) - 1) * 100
                
            # Calculate volatility if we have enough return data
            if len(return_df) > 1:
                volatility = return_df['return_pct'].std()
    
    # Calculate max drawdown if value is available
    if 'value' in performance_df.columns:
        # Drop any NaN values for value
        value_df = performance_df.dropna(subset=['value'])
        
        if not value_df.empty and len(value_df) > 1:
            # Calculate rolling maximum
            rolling_max = value_df['value'].cummax()
            # Calculate drawdown
            drawdown = (value_df['value'] - rolling_max) / rolling_max
            max_drawdown = drawdown.min() * 100  # Convert to percentage
    
    # Calculate portfolio allocation if available
    if 'asset_type' in performance_df.columns and 'allocation_pct' in performance_df.columns:
        # Filter out rows that have both asset_type and allocation_pct
        alloc_df = performance_df.dropna(subset=['asset_type', 'allocation_pct'])
        
        if not alloc_df.empty:
            # Take the most recent allocation
            latest_date = alloc_df['date'].max()
            latest_allocation = alloc_df[alloc_df['date'] == latest_date]
            
            # Only create allocation dict if we have valid data
            if not latest_allocation.empty:
                allocation = {}
                for _, row in latest_allocation.iterrows():
                    if row['asset_type'] is not None and row['allocation_pct'] is not None:
                        allocation[row['asset_type']] = row['allocation_pct']
    
    return {
        "ytd_return": round(ytd_return, 2),
        "one_yr_return": round(one_yr_return, 2),
        "three_yr_return": round(three_yr_return, 2),
        "five_yr_return": round(five_yr_return, 2),
        "volatility": round(volatility, 2),
        "max_drawdown": round(max_drawdown, 2),
        "allocation": allocation
    }

def generate_performance_chart_data(performance_df):
    """
    Generate data for performance charts
    
    Args:
        performance_df: DataFrame containing performance data
        
    Returns:
        Dictionary with chart data
    """
    if performance_df.empty:
        return {"error": "No performance data available"}
    
    # Ensure date is datetime
    if 'date' in performance_df.columns:
        performance_df['date'] = pd.to_datetime(performance_df['date'])
        performance_df = performance_df.sort_values('date')
    
    # Generate time series data for account value
    value_chart_data = []
    if 'date' in performance_df.columns and 'value' in performance_df.columns:
        value_chart_data = [
            {"date": date.strftime("%Y-%m-%d"), "value": value}
            for date, value in zip(performance_df['date'], performance_df['value'])
        ]
    
    # Generate time series data for returns
    return_chart_data = []
    if 'date' in performance_df.columns and 'return_pct' in performance_df.columns:
        return_chart_data = [
            {"date": date.strftime("%Y-%m-%d"), "return": ret}
            for date, ret in zip(performance_df['date'], performance_df['return_pct'])
        ]
    
    # Generate current asset allocation
    allocation_data = []
    if 'asset_type' in performance_df.columns and 'allocation_pct' in performance_df.columns:
        # Take the most recent allocation
        latest_date = performance_df['date'].max()
        latest_allocation = performance_df[performance_df['date'] == latest_date]
        allocation_data = [
            {"asset": asset, "percentage": pct}
            for asset, pct in zip(latest_allocation['asset_type'], latest_allocation['allocation_pct'])
        ]
    
    return {
        "value_chart": value_chart_data,
        "return_chart": return_chart_data,
        "allocation_chart": allocation_data
    }
