-- Financial Advisor Platform Schema
-- Generated from SQLAlchemy

-- Table: households

CREATE TABLE households (
	id INTEGER DEFAULT nextval('households_id_seq'::regclass) NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	email VARCHAR(100), 
	phone VARCHAR(20), 
	birth_date TIMESTAMP, 
	risk_profile VARCHAR(50), 
	segment VARCHAR(50), 
	total_assets DOUBLE PRECISION, 
	created_at TIMESTAMP, 
	updated_at TIMESTAMP, 
	CONSTRAINT households_pkey PRIMARY KEY (id)
);

-- Table: accounts

CREATE TABLE accounts (
	id INTEGER DEFAULT nextval('accounts_id_seq'::regclass) NOT NULL, 
	household_id INTEGER NOT NULL, 
	account_type VARCHAR(50), 
	opening_date TIMESTAMP, 
	current_balance DOUBLE PRECISION, 
	currency VARCHAR(10), 
	created_at TIMESTAMP, 
	updated_at TIMESTAMP, 
	CONSTRAINT accounts_pkey PRIMARY KEY (id), 
	CONSTRAINT accounts_household_id_fkey FOREIGN KEY(household_id) REFERENCES households (id)
);

-- Table: activities

CREATE TABLE activities (
	id INTEGER DEFAULT nextval('activities_id_seq'::regclass) NOT NULL, 
	account_id INTEGER NOT NULL, 
	date TIMESTAMP NOT NULL, 
	type VARCHAR(50), 
	description VARCHAR(255), 
	amount DOUBLE PRECISION, 
	created_at TIMESTAMP, 
	CONSTRAINT activities_pkey PRIMARY KEY (id), 
	CONSTRAINT activities_account_id_fkey FOREIGN KEY(account_id) REFERENCES accounts (id)
);

-- Table: performance

CREATE TABLE performance (
	id INTEGER DEFAULT nextval('performance_id_seq'::regclass) NOT NULL, 
	account_id INTEGER NOT NULL, 
	date TIMESTAMP NOT NULL, 
	value DOUBLE PRECISION, 
	return_pct DOUBLE PRECISION, 
	asset_type VARCHAR(50), 
	allocation_pct DOUBLE PRECISION, 
	created_at TIMESTAMP, 
	CONSTRAINT performance_pkey PRIMARY KEY (id), 
	CONSTRAINT performance_account_id_fkey FOREIGN KEY(account_id) REFERENCES accounts (id)
);

-- Table: financial_goals

CREATE TABLE financial_goals (
	id INTEGER DEFAULT nextval('financial_goals_id_seq'::regclass) NOT NULL, 
	household_id INTEGER NOT NULL, 
	account_id INTEGER, 
	name VARCHAR(100) NOT NULL, 
	description TEXT, 
	target_amount DOUBLE PRECISION NOT NULL, 
	current_amount DOUBLE PRECISION, 
	start_date TIMESTAMP, 
	target_date TIMESTAMP, 
	category VARCHAR(50), 
	status VARCHAR(20), 
	priority INTEGER, 
	created_at TIMESTAMP, 
	updated_at TIMESTAMP, 
	CONSTRAINT financial_goals_pkey PRIMARY KEY (id), 
	CONSTRAINT financial_goals_account_id_fkey FOREIGN KEY(account_id) REFERENCES accounts (id), 
	CONSTRAINT financial_goals_household_id_fkey FOREIGN KEY(household_id) REFERENCES households (id)
);

-- Table: goal_progress_updates

CREATE TABLE goal_progress_updates (
	id INTEGER DEFAULT nextval('goal_progress_updates_id_seq'::regclass) NOT NULL, 
	goal_id INTEGER NOT NULL, 
	date TIMESTAMP, 
	amount DOUBLE PRECISION NOT NULL, 
	note TEXT, 
	created_at TIMESTAMP, 
	CONSTRAINT goal_progress_updates_pkey PRIMARY KEY (id), 
	CONSTRAINT goal_progress_updates_goal_id_fkey FOREIGN KEY(goal_id) REFERENCES financial_goals (id)
);


-- Foreign Keys for accounts
-- {'name': 'accounts_household_id_fkey', 'constrained_columns': ['household_id'], 'referred_schema': None, 'referred_table': 'households', 'referred_columns': ['id'], 'options': {}, 'comment': None}

-- Foreign Keys for activities
-- {'name': 'activities_account_id_fkey', 'constrained_columns': ['account_id'], 'referred_schema': None, 'referred_table': 'accounts', 'referred_columns': ['id'], 'options': {}, 'comment': None}

-- Foreign Keys for performance
-- {'name': 'performance_account_id_fkey', 'constrained_columns': ['account_id'], 'referred_schema': None, 'referred_table': 'accounts', 'referred_columns': ['id'], 'options': {}, 'comment': None}

-- Foreign Keys for financial_goals
-- {'name': 'financial_goals_account_id_fkey', 'constrained_columns': ['account_id'], 'referred_schema': None, 'referred_table': 'accounts', 'referred_columns': ['id'], 'options': {}, 'comment': None}
-- {'name': 'financial_goals_household_id_fkey', 'constrained_columns': ['household_id'], 'referred_schema': None, 'referred_table': 'households', 'referred_columns': ['id'], 'options': {}, 'comment': None}

-- Foreign Keys for goal_progress_updates
-- {'name': 'goal_progress_updates_goal_id_fkey', 'constrained_columns': ['goal_id'], 'referred_schema': None, 'referred_table': 'financial_goals', 'referred_columns': ['id'], 'options': {}, 'comment': None}

