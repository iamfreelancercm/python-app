from flask import Flask, request, jsonify, send_file, render_template, send_from_directory
from flask_cors import CORS
import os
import pandas as pd
from datetime import datetime
import dateutil.parser

from excel_handler import read_excel_file, write_excel_file
from data_processor import process_client_data, process_account_performance
from main import app, db
from models import Household, Account, Activity, Performance, FinancialGoal, GoalProgressUpdate

# Initialize app
CORS(app)  # Enable CORS for all routes

# Define upload folder for Excel files
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Define static folder for web interface
STATIC_FOLDER = 'static'
if not os.path.exists(STATIC_FOLDER):
    os.makedirs(STATIC_FOLDER)

# Define reports folder
REPORTS_FOLDER = 'reports'
if not os.path.exists(REPORTS_FOLDER):
    os.makedirs(REPORTS_FOLDER)

@app.route('/')
def index():
    # Check if we have the static HTML interface
    if os.path.exists(os.path.join(STATIC_FOLDER, 'index.html')):
        return send_from_directory(STATIC_FOLDER, 'index.html')
    else:
        return jsonify({"message": "Financial Advisor API is running"})

@app.route('/api/households', methods=['GET'])
def get_households():
    """Return list of all households (clients)"""
    try:
        households = Household.query.all()
        return jsonify([household.to_dict() for household in households])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/households/<int:household_id>', methods=['GET'])
def get_household(household_id):
    """Return a specific household details"""
    try:
        household = Household.query.get(household_id)
        if household:
            return jsonify(household.to_dict())
        else:
            return jsonify({"error": f"Household with ID {household_id} not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/households/<int:household_id>/accounts', methods=['GET'])
def get_household_accounts(household_id):
    """Return all accounts for a specific household"""
    try:
        accounts = Account.query.filter_by(household_id=household_id).all()
        return jsonify([account.to_dict() for account in accounts])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/accounts/<int:account_id>/activities', methods=['GET'])
def get_account_activities(account_id):
    """Return recent activities for a specific account"""
    try:
        activities = Activity.query.filter_by(account_id=account_id).order_by(Activity.date.desc()).all()
        return jsonify([activity.to_dict() for activity in activities])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/accounts/<int:account_id>/performance', methods=['GET'])
def get_account_performance(account_id):
    """Return performance metrics for a specific account"""
    try:
        # Get all performance records for this account
        performance_records = Performance.query.filter_by(account_id=account_id).all()
        
        # Convert to DataFrame for processing with existing functions
        performance_data = []
        for record in performance_records:
            record_data = {
                'account_id': record.account_id,
                'date': record.date
            }
            
            # Only add non-null values
            if record.value is not None:
                record_data['value'] = record.value
                
            if record.return_pct is not None:
                record_data['return_pct'] = record.return_pct
                
            if record.asset_type is not None:
                record_data['asset_type'] = record.asset_type
                
            if record.allocation_pct is not None:
                record_data['allocation_pct'] = record.allocation_pct
            
            performance_data.append(record_data)
        
        if not performance_data:
            return jsonify({"error": "No performance data available for this account"}), 404
            
        # Convert to DataFrame and process
        performance_df = pd.DataFrame(performance_data)
        metrics = process_account_performance(performance_df)
        return jsonify(metrics)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/import/excel', methods=['POST'])
def import_excel():
    """Import client data from an uploaded Excel file"""
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if not file.filename.endswith(('.xlsx', '.xls', '.csv')):
        return jsonify({"error": "Invalid file format, please upload Excel or CSV file"}), 400
    
    try:
        # Save the file temporarily
        filepath = os.path.join(UPLOAD_FOLDER, file.filename)
        file.save(filepath)
        
        # Process the file
        sheet_names = pd.ExcelFile(filepath).sheet_names
        
        # Import data into database
        import_count = {
            'households': 0,
            'accounts': 0,
            'activities': 0,
            'performance': 0
        }
        
        # Process each sheet
        for sheet in sheet_names:
            df = read_excel_file(filepath, sheet)
            
            # Import households
            if sheet.lower() == 'clients' or sheet.lower() == 'households':
                for _, row in df.iterrows():
                    # Check if household already exists
                    household = Household.query.filter_by(id=row.get('client_id', row.get('household_id', row.get('id')))).first()
                    
                    if not household:
                        household = Household(
                            id=row.get('client_id', row.get('household_id', row.get('id'))),
                            name=row.get('name', ''),
                            email=row.get('email', ''),
                            phone=row.get('phone', ''),
                            birth_date=dateutil.parser.parse(row['birth_date']) if 'birth_date' in row and row['birth_date'] else None,
                            risk_profile=row.get('risk_profile', ''),
                            segment=row.get('segment', ''),
                            total_assets=row.get('total_assets', 0)
                        )
                        db.session.add(household)
                        import_count['households'] += 1
            
            # Import accounts
            elif sheet.lower() == 'accounts':
                for _, row in df.iterrows():
                    # Check if account already exists
                    account = Account.query.filter_by(id=row.get('account_id', row.get('id'))).first()
                    
                    if not account:
                        account = Account(
                            id=row.get('account_id', row.get('id')),
                            household_id=row.get('client_id', row.get('household_id')),
                            account_type=row.get('account_type', ''),
                            opening_date=dateutil.parser.parse(row['opening_date']) if 'opening_date' in row and row['opening_date'] else None,
                            current_balance=row.get('current_balance', 0),
                            currency=row.get('currency', 'USD')
                        )
                        db.session.add(account)
                        import_count['accounts'] += 1
            
            # Import activities
            elif sheet.lower() == 'activities':
                for _, row in df.iterrows():
                    # Check if activity already exists
                    activity = Activity.query.filter_by(id=row.get('activity_id', row.get('id'))).first()
                    
                    if not activity:
                        activity = Activity(
                            id=row.get('activity_id', row.get('id')),
                            account_id=row.get('account_id'),
                            date=dateutil.parser.parse(row['date']) if 'date' in row and row['date'] else datetime.now(),
                            type=row.get('type', ''),
                            description=row.get('description', ''),
                            amount=row.get('amount', 0)
                        )
                        db.session.add(activity)
                        import_count['activities'] += 1
            
            # Import performance
            elif sheet.lower() == 'performance':
                for _, row in df.iterrows():
                    # Check if performance record already exists
                    performance = Performance.query.filter_by(id=row.get('record_id', row.get('id'))).first()
                    
                    if not performance:
                        performance = Performance(
                            id=row.get('record_id', row.get('id')),
                            account_id=row.get('account_id'),
                            date=dateutil.parser.parse(row['date']) if 'date' in row and row['date'] else datetime.now(),
                            value=row.get('value'),
                            return_pct=row.get('return_pct'),
                            asset_type=row.get('asset_type'),
                            allocation_pct=row.get('allocation_pct')
                        )
                        db.session.add(performance)
                        import_count['performance'] += 1
        
        # Commit all changes to database
        db.session.commit()
        
        # Clean up the file
        os.remove(filepath)
        
        return jsonify({
            "message": "Data imported successfully",
            "import_count": import_count
        })
    except Exception as e:
        # Rollback in case of error
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# Create sample data
@app.route('/api/create-sample-data', methods=['POST'])
def create_sample_data():
    """Create sample data in the database"""
    try:
        from excel_handler import create_sample_excel
        
        # Create sample Excel file
        sample_file = create_sample_excel()
        
        # Process the Excel file directly without going through import_excel
        try:
            # Define the sheets to process
            sheets = ['Clients', 'Accounts', 'Activities', 'Performance']
            
            # Import counts
            import_count = {
                'households': 0,
                'accounts': 0,
                'activities': 0,
                'performance': 0
            }
            
            # Load the Excel file into a dictionary of DataFrames
            excel_data = pd.read_excel(sample_file, sheet_name=sheets)
            
            # Process clients/households
            if 'Clients' in excel_data:
                df = excel_data['Clients']
                for _, row in df.iterrows():
                    # Check if household already exists
                    household = Household.query.filter_by(id=row.get('client_id')).first()
                    
                    if not household:
                        household = Household(
                            id=row.get('client_id'),
                            name=row.get('name', ''),
                            email=row.get('email', ''),
                            phone=row.get('phone', ''),
                            birth_date=dateutil.parser.parse(row['birth_date']) if 'birth_date' in row and pd.notna(row['birth_date']) else None,
                            risk_profile=row.get('risk_profile', ''),
                            segment=row.get('segment', ''),
                            total_assets=row.get('total_assets', 0)
                        )
                        db.session.add(household)
                        import_count['households'] += 1
            
            # Process accounts
            if 'Accounts' in excel_data:
                df = excel_data['Accounts']
                for _, row in df.iterrows():
                    # Check if account already exists
                    account = Account.query.filter_by(id=row.get('account_id')).first()
                    
                    if not account:
                        account = Account(
                            id=row.get('account_id'),
                            household_id=row.get('client_id'),
                            account_type=row.get('account_type', ''),
                            opening_date=dateutil.parser.parse(row['opening_date']) if 'opening_date' in row and pd.notna(row['opening_date']) else None,
                            current_balance=row.get('current_balance', 0),
                            currency=row.get('currency', 'USD')
                        )
                        db.session.add(account)
                        import_count['accounts'] += 1
            
            # Process activities
            if 'Activities' in excel_data:
                df = excel_data['Activities']
                for _, row in df.iterrows():
                    # Check if activity already exists
                    activity = Activity.query.filter_by(id=row.get('activity_id')).first()
                    
                    if not activity:
                        activity = Activity(
                            id=row.get('activity_id'),
                            account_id=row.get('account_id'),
                            date=dateutil.parser.parse(row['date']) if 'date' in row and pd.notna(row['date']) else datetime.now(),
                            type=row.get('type', ''),
                            description=row.get('description', ''),
                            amount=row.get('amount', 0)
                        )
                        db.session.add(activity)
                        import_count['activities'] += 1
            
            # Process performance
            if 'Performance' in excel_data:
                df = excel_data['Performance']
                for _, row in df.iterrows():
                    # Check if performance record already exists
                    performance = Performance.query.filter_by(id=row.get('record_id')).first()
                    
                    if not performance:
                        # Create a new performance record
                        perf_data = {
                            'id': row.get('record_id'),
                            'account_id': row.get('account_id'),
                            'date': dateutil.parser.parse(row['date']) if 'date' in row and pd.notna(row['date']) else datetime.now(),
                        }
                        
                        # Handle optional fields
                        if 'value' in row and pd.notna(row['value']):
                            perf_data['value'] = row['value']
                        
                        if 'return_pct' in row and pd.notna(row['return_pct']):
                            perf_data['return_pct'] = row['return_pct']
                            
                        if 'asset_type' in row and pd.notna(row['asset_type']):
                            perf_data['asset_type'] = row['asset_type']
                            
                        if 'allocation_pct' in row and pd.notna(row['allocation_pct']):
                            perf_data['allocation_pct'] = row['allocation_pct']
                        
                        performance = Performance(**perf_data)
                        db.session.add(performance)
                        import_count['performance'] += 1
            
            # Commit all changes to database
            db.session.commit()
            
            # Clean up the file
            os.remove(sample_file)
            
            return jsonify({
                "message": "Sample data created successfully",
                "import_count": import_count
            })
            
        except Exception as e:
            # Rollback in case of error
            db.session.rollback()
            raise Exception(f"Error importing sample data: {str(e)}")
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# PDF Report Generation Endpoints
from pdf_generator import generate_client_summary_report, generate_account_performance_report

@app.route('/api/reports/client/<int:household_id>', methods=['GET'])
def generate_client_report(household_id):
    """Generate a PDF summary report for a client/household"""
    try:
        # Get the household data
        household = Household.query.get(household_id)
        if not household:
            return jsonify({"error": f"Household with ID {household_id} not found"}), 404
        
        # Get all accounts for this household
        accounts = Account.query.filter_by(household_id=household_id).all()
        
        # Generate the PDF report
        report_path = generate_client_summary_report(
            client_data=household.to_dict(),
            accounts_data=[account.to_dict() for account in accounts]
        )
        
        # Return the PDF file
        filename = os.path.basename(report_path)
        return send_file(
            report_path,
            mimetype='application/pdf',
            as_attachment=True,
            download_name=filename
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/reports/account/<int:account_id>', methods=['GET'])
def generate_account_report(account_id):
    """Generate a PDF performance report for an account"""
    try:
        # Get the account data
        account = Account.query.get(account_id)
        if not account:
            return jsonify({"error": f"Account with ID {account_id} not found"}), 404
        
        # Get performance data
        performance_records = Performance.query.filter_by(account_id=account_id).all()
        
        # Convert to DataFrame for processing
        performance_data = []
        for record in performance_records:
            record_data = {
                'account_id': record.account_id,
                'date': record.date
            }
            
            # Only add non-null values
            if record.value is not None:
                record_data['value'] = record.value
                
            if record.return_pct is not None:
                record_data['return_pct'] = record.return_pct
                
            if record.asset_type is not None:
                record_data['asset_type'] = record.asset_type
                
            if record.allocation_pct is not None:
                record_data['allocation_pct'] = record.allocation_pct
            
            performance_data.append(record_data)
        
        # Process performance data if available
        if performance_data:
            performance_df = pd.DataFrame(performance_data)
            metrics = process_account_performance(performance_df)
        else:
            metrics = {}
        
        # Get recent activities
        activities = Activity.query.filter_by(account_id=account_id).order_by(Activity.date.desc()).limit(10).all()
        activities_data = [activity.to_dict() for activity in activities]
        
        # Generate the PDF report
        report_path = generate_account_performance_report(
            account_data=account.to_dict(),
            performance_data=metrics,
            activities_data=activities_data
        )
        
        # Return the PDF file
        filename = os.path.basename(report_path)
        return send_file(
            report_path,
            mimetype='application/pdf',
            as_attachment=True,
            download_name=filename
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Financial Goals API endpoints
@app.route('/api/households/<int:household_id>/goals', methods=['GET'])
def get_household_goals(household_id):
    """Return all financial goals for a specific household"""
    try:
        goals = FinancialGoal.query.filter_by(household_id=household_id).all()
        return jsonify([goal.to_dict() for goal in goals])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/accounts/<int:account_id>/goals', methods=['GET'])
def get_account_goals(account_id):
    """Return all financial goals for a specific account"""
    try:
        goals = FinancialGoal.query.filter_by(account_id=account_id).all()
        return jsonify([goal.to_dict() for goal in goals])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/goals/<int:goal_id>', methods=['GET'])
def get_goal(goal_id):
    """Return a specific financial goal"""
    try:
        goal = FinancialGoal.query.get(goal_id)
        if goal:
            # Include progress updates
            goal_dict = goal.to_dict()
            goal_dict['progress_updates'] = [update.to_dict() for update in goal.progress_updates]
            return jsonify(goal_dict)
        else:
            return jsonify({"error": f"Financial goal with ID {goal_id} not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/goals', methods=['POST'])
def create_goal():
    """Create a new financial goal"""
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['household_id', 'name', 'target_amount']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
        
        # Check if household exists
        household = Household.query.get(data['household_id'])
        if not household:
            return jsonify({"error": f"Household with ID {data['household_id']} not found"}), 404
        
        # Check if account exists (if account_id is provided)
        if 'account_id' in data and data['account_id']:
            account = Account.query.get(data['account_id'])
            if not account:
                return jsonify({"error": f"Account with ID {data['account_id']} not found"}), 404
        
        # Create new goal
        goal = FinancialGoal(
            household_id=data['household_id'],
            account_id=data.get('account_id'),
            name=data['name'],
            description=data.get('description', ''),
            target_amount=data['target_amount'],
            current_amount=data.get('current_amount', 0.0),
            category=data.get('category', 'General'),
            priority=data.get('priority', 1)
        )
        
        # Handle dates
        if 'start_date' in data and data['start_date']:
            goal.start_date = dateutil.parser.parse(data['start_date'])
        
        if 'target_date' in data and data['target_date']:
            goal.target_date = dateutil.parser.parse(data['target_date'])
        
        db.session.add(goal)
        db.session.commit()
        
        return jsonify(goal.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/api/goals/<int:goal_id>', methods=['PUT'])
def update_goal(goal_id):
    """Update a financial goal"""
    try:
        goal = FinancialGoal.query.get(goal_id)
        if not goal:
            return jsonify({"error": f"Financial goal with ID {goal_id} not found"}), 404
        
        data = request.json
        
        # Update fields
        if 'name' in data:
            goal.name = data['name']
        
        if 'description' in data:
            goal.description = data['description']
        
        if 'target_amount' in data:
            goal.target_amount = data['target_amount']
        
        if 'current_amount' in data:
            goal.current_amount = data['current_amount']
        
        if 'category' in data:
            goal.category = data['category']
        
        if 'priority' in data:
            goal.priority = data['priority']
        
        if 'status' in data:
            goal.status = data['status']
        
        if 'start_date' in data and data['start_date']:
            goal.start_date = dateutil.parser.parse(data['start_date'])
        
        if 'target_date' in data and data['target_date']:
            goal.target_date = dateutil.parser.parse(data['target_date'])
        
        # Check if status should be updated based on progress
        if goal.current_amount >= goal.target_amount and goal.status != 'Completed':
            goal.status = 'Completed'
        
        goal.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(goal.to_dict())
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/api/goals/<int:goal_id>/progress', methods=['POST'])
def add_goal_progress(goal_id):
    """Add a progress update to a financial goal"""
    try:
        goal = FinancialGoal.query.get(goal_id)
        if not goal:
            return jsonify({"error": f"Financial goal with ID {goal_id} not found"}), 404
        
        data = request.json
        
        # Validate required fields
        if 'amount' not in data:
            return jsonify({"error": "Missing required field: amount"}), 400
        
        # Create progress update
        progress = GoalProgressUpdate(
            goal_id=goal_id,
            amount=data['amount'],
            note=data.get('note', '')
        )
        
        if 'date' in data and data['date']:
            progress.date = dateutil.parser.parse(data['date'])
        
        # Update goal current amount
        goal.current_amount += data['amount']
        
        # Check if goal is now completed
        if goal.current_amount >= goal.target_amount and goal.status != 'Completed':
            goal.status = 'Completed'
        
        goal.updated_at = datetime.utcnow()
        
        db.session.add(progress)
        db.session.commit()
        
        # Return updated goal with progress
        goal_dict = goal.to_dict()
        goal_dict['progress_updates'] = [update.to_dict() for update in goal.progress_updates]
        
        return jsonify(goal_dict)
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/api/goals/<int:goal_id>', methods=['DELETE'])
def delete_goal(goal_id):
    """Delete a financial goal"""
    try:
        goal = FinancialGoal.query.get(goal_id)
        if not goal:
            return jsonify({"error": f"Financial goal with ID {goal_id} not found"}), 404
        
        db.session.delete(goal)
        db.session.commit()
        
        return jsonify({"message": f"Financial goal with ID {goal_id} deleted successfully"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# Create sample financial goal data
@app.route('/api/create-sample-goals', methods=['POST'])
def create_sample_goals():
    """Create sample financial goal data for testing"""
    try:
        import random
        import traceback
        from datetime import timedelta
        
        # Just create a simple test goal for one account
        accounts = Account.query.all()
        
        if not accounts:
            return jsonify({"error": "No accounts found. Please create accounts first."}), 400
        
        # Get the first account
        account = accounts[0]
        
        # Create a simple goal
        goal = FinancialGoal(
            household_id=account.household_id,
            account_id=account.id,
            name="Test Retirement Goal",
            description="Saving for retirement",
            target_amount=500000.0,
            current_amount=150000.0,
            start_date=datetime.utcnow() - timedelta(days=365),
            target_date=datetime.utcnow() + timedelta(days=3650),
            category="Retirement",
            priority=1,
            status='In Progress'
        )
        
        db.session.add(goal)
        
        # Add a simple progress update
        progress = GoalProgressUpdate(
            goal_id=goal.id,
            date=datetime.utcnow() - timedelta(days=30),
            amount=50000.0,
            note="Initial retirement savings"
        )
        
        db.session.add(progress)
        db.session.commit()
        
        return jsonify({
            "message": "Sample financial goal created successfully",
            "created_goals": 1
        })
    except Exception as e:
        db.session.rollback()
        error_details = traceback.format_exc()
        print(f"Error creating sample goals: {str(e)}")
        print(f"Traceback: {error_details}")
        return jsonify({"error": str(e), "traceback": error_details}), 500

# Tables are created in app_entry.py when run directly
# The following code will only run if this file is executed directly
if __name__ == '__main__':
    # Create all database tables
    with app.app_context():
        db.create_all()
    
    # Run the app
    app.run(host='0.0.0.0', port=5000, debug=True)
