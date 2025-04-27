from datetime import datetime
from backend.main import db

# Define database models

class Household(db.Model):
    """Household (client) model - represents a household/client in the financial advisor platform"""
    __tablename__ = 'households'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    birth_date = db.Column(db.DateTime)
    risk_profile = db.Column(db.String(50))
    segment = db.Column(db.String(50))
    total_assets = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship with accounts (one-to-many)
    accounts = db.relationship("Account", back_populates="household", cascade="all, delete-orphan")
    
    # Relationship with financial goals (one-to-many)
    financial_goals = db.relationship("FinancialGoal", back_populates="household", cascade="all, delete-orphan")
    
    def to_dict(self):
        """Convert instance to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'birth_date': self.birth_date.isoformat() if self.birth_date else None,
            'risk_profile': self.risk_profile,
            'segment': self.segment,
            'total_assets': self.total_assets,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }


class Account(db.Model):
    """Account model - represents a financial account belonging to a household"""
    __tablename__ = 'accounts'
    
    id = db.Column(db.Integer, primary_key=True)
    household_id = db.Column(db.Integer, db.ForeignKey('households.id'), nullable=False)
    account_type = db.Column(db.String(50))
    opening_date = db.Column(db.DateTime)
    current_balance = db.Column(db.Float)
    currency = db.Column(db.String(10), default='USD')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship with household (many-to-one)
    household = db.relationship("Household", back_populates="accounts")
    
    # Relationship with activities and performance (one-to-many)
    activities = db.relationship("Activity", back_populates="account", cascade="all, delete-orphan")
    performance_records = db.relationship("Performance", back_populates="account", cascade="all, delete-orphan")
    
    # Relationship with financial goals (one-to-many)
    financial_goals = db.relationship("FinancialGoal", back_populates="account")
    
    def to_dict(self):
        """Convert instance to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'household_id': self.household_id,
            'account_type': self.account_type,
            'opening_date': self.opening_date.isoformat() if self.opening_date else None,
            'current_balance': self.current_balance,
            'currency': self.currency,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }


class Activity(db.Model):
    """Activity model - represents financial activities/transactions on an account"""
    __tablename__ = 'activities'
    
    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'), nullable=False)
    date = db.Column(db.DateTime, nullable=False)
    type = db.Column(db.String(50))  # Deposit, Withdrawal, Buy, Sell, Dividend, etc.
    description = db.Column(db.String(255))
    amount = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationship with account (many-to-one)
    account = db.relationship("Account", back_populates="activities")
    
    def to_dict(self):
        """Convert instance to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'account_id': self.account_id,
            'date': self.date.isoformat() if self.date else None,
            'type': self.type,
            'description': self.description,
            'amount': self.amount,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class Performance(db.Model):
    """Performance model - represents performance metrics for an account"""
    __tablename__ = 'performance'
    
    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'), nullable=False)
    date = db.Column(db.DateTime, nullable=False)
    value = db.Column(db.Float)
    return_pct = db.Column(db.Float)
    asset_type = db.Column(db.String(50))
    allocation_pct = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationship with account (many-to-one)
    account = db.relationship("Account", back_populates="performance_records")
    
    def to_dict(self):
        """Convert instance to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'account_id': self.account_id,
            'date': self.date.isoformat() if self.date else None,
            'value': self.value,
            'return_pct': self.return_pct,
            'asset_type': self.asset_type,
            'allocation_pct': self.allocation_pct,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class FinancialGoal(db.Model):
    """Financial Goal model - represents financial goals for a household or account"""
    __tablename__ = 'financial_goals'

    id = db.Column(db.Integer, primary_key=True)
    household_id = db.Column(db.Integer, db.ForeignKey('households.id'), nullable=False)
    account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'), nullable=True)  # Optional, can be for a specific account
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    target_amount = db.Column(db.Float, nullable=False)
    current_amount = db.Column(db.Float, default=0.0)
    start_date = db.Column(db.DateTime, default=datetime.utcnow)
    target_date = db.Column(db.DateTime)
    category = db.Column(db.String(50))  # Retirement, Education, Home, etc.
    status = db.Column(db.String(20), default='In Progress')  # In Progress, Completed, Canceled
    priority = db.Column(db.Integer, default=1)  # 1=Highest, 5=Lowest
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Define relationships
    household = db.relationship("Household", back_populates="financial_goals")
    account = db.relationship("Account", back_populates="financial_goals")
    progress_updates = db.relationship("GoalProgressUpdate", back_populates="financial_goal", cascade="all, delete-orphan")

    def to_dict(self):
        """Convert instance to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'household_id': self.household_id,
            'account_id': self.account_id,
            'name': self.name,
            'description': self.description,
            'target_amount': self.target_amount,
            'current_amount': self.current_amount,
            'progress_percentage': round((self.current_amount / self.target_amount * 100), 2) if self.target_amount > 0 else 0,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'target_date': self.target_date.isoformat() if self.target_date else None,
            'days_remaining': (self.target_date - datetime.utcnow()).days if self.target_date else None,
            'category': self.category,
            'status': self.status,
            'priority': self.priority,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }


class GoalProgressUpdate(db.Model):
    """Goal Progress Update model - tracks updates to financial goal progress"""
    __tablename__ = 'goal_progress_updates'

    id = db.Column(db.Integer, primary_key=True)
    goal_id = db.Column(db.Integer, db.ForeignKey('financial_goals.id'), nullable=False)
    date = db.Column(db.DateTime, default=datetime.utcnow)
    amount = db.Column(db.Float, nullable=False)  # Amount added or subtracted
    note = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Define relationships
    financial_goal = db.relationship("FinancialGoal", back_populates="progress_updates")

    def to_dict(self):
        """Convert instance to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'goal_id': self.goal_id,
            'date': self.date.isoformat() if self.date else None,
            'amount': self.amount,
            'note': self.note,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }