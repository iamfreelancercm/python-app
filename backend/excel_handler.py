import pandas as pd
import numpy as np
import os
from openpyxl import load_workbook, Workbook

def read_excel_file(file_path, sheet_name=None):
    """
    Read data from an Excel file
    
    Args:
        file_path: Path to the Excel file
        sheet_name: Name of the sheet to read (optional)
        
    Returns:
        DataFrame with the Excel data
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")
    
    if file_path.endswith('.csv'):
        return pd.read_csv(file_path)
    
    try:
        if sheet_name:
            # Read a specific sheet
            return pd.read_excel(file_path, sheet_name=sheet_name)
        else:
            # Read all sheets into a dictionary of DataFrames
            return pd.read_excel(file_path, sheet_name=None)
    except Exception as e:
        raise Exception(f"Error reading Excel file: {str(e)}")

def write_excel_file(file_path, data_dict):
    """
    Write data to an Excel file with multiple sheets
    
    Args:
        file_path: Path to write the Excel file
        data_dict: Dictionary mapping sheet names to DataFrames
        
    Returns:
        Path to the written file
    """
    try:
        with pd.ExcelWriter(file_path, engine='openpyxl') as writer:
            for sheet_name, df in data_dict.items():
                df.to_excel(writer, sheet_name=sheet_name, index=False)
        return file_path
    except Exception as e:
        raise Exception(f"Error writing Excel file: {str(e)}")

def get_excel_sheet_names(file_path):
    """
    Get list of sheet names from an Excel file
    
    Args:
        file_path: Path to the Excel file
        
    Returns:
        List of sheet names
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")
    
    try:
        if file_path.endswith('.csv'):
            return ["Sheet1"]  # CSV files have only one sheet
        
        # For Excel files, return all sheet names
        return pd.ExcelFile(file_path).sheet_names
    except Exception as e:
        raise Exception(f"Error reading Excel file: {str(e)}")

def create_sample_excel():
    """
    Create a sample Excel file with financial advisor data
    
    Returns:
        Path to the created file
    """
    # Create directory if it doesn't exist
    os.makedirs('sample_data', exist_ok=True)
    
    file_path = 'sample_data/client_accounts.xlsx'
    
    # Create sample client data
    clients_df = pd.DataFrame({
        'client_id': [1, 2, 3, 4, 5],
        'name': ['John Smith', 'Jane Doe', 'Robert Johnson', 'Maria Garcia', 'David Chen'],
        'email': ['john@example.com', 'jane@example.com', 'robert@example.com', 
                  'maria@example.com', 'david@example.com'],
        'phone': ['555-123-4567', '555-234-5678', '555-345-6789', '555-456-7890', '555-567-8901'],
        'birth_date': ['1975-05-15', '1982-11-30', '1968-03-22', '1990-07-08', '1955-12-01'],
        'risk_profile': ['Conservative', 'Moderate', 'Aggressive', 'Moderate', 'Conservative'],
        'segment': ['High Net Worth', 'Mass Affluent', 'High Net Worth', 
                    'Mass Affluent', 'Ultra High Net Worth'],
        'total_assets': [1250000, 450000, 2300000, 350000, 5600000]
    })
    
    # Create sample account data
    accounts_df = pd.DataFrame({
        'account_id': [101, 102, 103, 104, 105, 106, 107],
        'client_id': [1, 1, 2, 3, 3, 4, 5],
        'account_type': ['IRA', 'Brokerage', 'Roth IRA', 'Brokerage', '401(k) Rollover', 
                         'Brokerage', 'Trust'],
        'opening_date': ['2015-03-10', '2015-03-15', '2018-06-22', '2010-11-05', 
                         '2012-05-18', '2019-02-28', '2005-08-12'],
        'current_balance': [450000, 800000, 450000, 1200000, 1100000, 350000, 5600000],
        'currency': ['USD', 'USD', 'USD', 'USD', 'USD', 'USD', 'USD']
    })
    
    # Create sample activity data
    activities_df = pd.DataFrame({
        'activity_id': list(range(1, 21)),
        'account_id': [101, 101, 102, 102, 102, 103, 103, 104, 104, 105, 105, 106, 106, 107, 107, 107, 101, 103, 104, 107],
        'date': ['2023-01-15', '2023-02-20', '2023-01-05', '2023-02-10', '2023-03-15', 
                 '2023-01-25', '2023-03-05', '2023-02-15', '2023-03-20', '2023-01-10', 
                 '2023-02-25', '2023-01-30', '2023-03-10', '2023-01-05', '2023-02-05', 
                 '2023-03-05', '2023-03-25', '2023-03-28', '2023-03-21', '2023-03-22'],
        'type': ['Deposit', 'Dividend', 'Buy', 'Sell', 'Dividend', 'Deposit', 'Buy', 
                 'Sell', 'Buy', 'Transfer In', 'Dividend', 'Deposit', 'Buy', 'Sell', 
                 'Dividend', 'Buy', 'Withdrawal', 'Fee', 'Dividend', 'Transfer Out'],
        'description': ['Contribution', 'Quarterly Dividend', 'Purchase - AAPL', 'Sale - MSFT', 
                        'Quarterly Dividend', 'Contribution', 'Purchase - VTI', 'Sale - BND', 
                        'Purchase - GOOGL', '401k Rollover', 'Quarterly Dividend', 'Contribution', 
                        'Purchase - AMZN', 'Sale - TSLA', 'Quarterly Dividend', 'Purchase - VT', 
                        'Client Withdrawal', 'Management Fee', 'Special Dividend', 'External Transfer'],
        'amount': [10000, 2500, -15000, 12000, 3000, 6000, -8000, 10000, -12000, 
                   350000, 4500, 5000, -6000, 25000, 15000, -30000, -5000, -1250, 
                   2200, -75000]
    })
    
    # Create sample performance data
    # Generate dates for the past 5 years, monthly
    from datetime import datetime, timedelta
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=5*365)
    dates = pd.date_range(start=start_date, end=end_date, freq='M')
    
    performance_records = []
    account_ids = [101, 102, 103, 104, 105, 106, 107]
    
    # Initial values for each account
    initial_values = {
        101: 300000,
        102: 600000,
        103: 350000,
        104: 900000,
        105: 800000,
        106: 280000,
        107: 4500000
    }
    
    # Asset allocation for each account (simplified)
    allocations = {
        101: [('Stocks', 40), ('Bonds', 50), ('Cash', 10)],
        102: [('Stocks', 70), ('Bonds', 25), ('Cash', 5)],
        103: [('Stocks', 80), ('Bonds', 15), ('Cash', 5)],
        104: [('Stocks', 65), ('Bonds', 30), ('Cash', 5)],
        105: [('Stocks', 55), ('Bonds', 40), ('Cash', 5)],
        106: [('Stocks', 75), ('Bonds', 20), ('Cash', 5)],
        107: [('Stocks', 60), ('Real Estate', 20), ('Bonds', 15), ('Cash', 5)]
    }
    
    # Generate performance data
    record_id = 1
    for account_id in account_ids:
        current_value = initial_values[account_id]
        for date in dates:
            # Generate a random monthly return between -3% and +5%
            monthly_return = (np.random.random() * 8 - 3) / 100
            current_value = current_value * (1 + monthly_return)
            
            # Add performance record
            performance_records.append({
                'record_id': record_id,
                'account_id': account_id,
                'date': date.strftime('%Y-%m-%d'),
                'value': round(current_value, 2),
                'return_pct': round(monthly_return * 100, 2)
            })
            record_id += 1
            
            # Add allocation records for each asset class (only for the most recent date)
            if date == dates[-1]:
                for asset_type, allocation_pct in allocations[account_id]:
                    performance_records.append({
                        'record_id': record_id,
                        'account_id': account_id,
                        'date': date.strftime('%Y-%m-%d'),
                        'asset_type': asset_type,
                        'allocation_pct': allocation_pct
                    })
                    record_id += 1
    
    performance_df = pd.DataFrame(performance_records)
    
    # Write to Excel file
    with pd.ExcelWriter(file_path) as writer:
        clients_df.to_excel(writer, sheet_name='Clients', index=False)
        accounts_df.to_excel(writer, sheet_name='Accounts', index=False)
        activities_df.to_excel(writer, sheet_name='Activities', index=False)
        performance_df.to_excel(writer, sheet_name='Performance', index=False)
    
    return file_path

# Create sample Excel file when module is imported
if __name__ == "__main__":
    create_sample_excel()
