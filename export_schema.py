"""
Export database schema using SQLAlchemy
This script extracts the current database schema into SQL format
"""
import os
import sys
from sqlalchemy import create_engine, MetaData, inspect
from sqlalchemy.schema import CreateTable

# Add backend directory to path so we can import the models
sys.path.insert(0, os.path.abspath('.'))

# Get database URL from environment
database_url = os.environ.get('DATABASE_URL')
if not database_url:
    print("ERROR: DATABASE_URL environment variable not set.")
    sys.exit(1)

print(f"Connecting to database...")
engine = create_engine(database_url)
inspector = inspect(engine)
metadata = MetaData()
metadata.reflect(bind=engine)

print(f"Found {len(metadata.tables)} tables in database.")

# Create SQL schema file
with open('schema.sql', 'w') as f:
    f.write("-- Financial Advisor Platform Schema\n")
    f.write("-- Generated from SQLAlchemy\n\n")
    
    # Write CREATE TABLE statements
    for table_name in inspector.get_table_names():
        table = metadata.tables[table_name]
        create_table = CreateTable(table)
        f.write(f"-- Table: {table_name}\n")
        f.write(str(create_table).rstrip() + ";\n\n")
    
    # Write foreign key constraints and indexes
    for table_name in inspector.get_table_names():
        fks = inspector.get_foreign_keys(table_name)
        if fks:
            f.write(f"-- Foreign Keys for {table_name}\n")
            for fk in fks:
                f.write(f"-- {fk}\n")
        
        indexes = inspector.get_indexes(table_name)
        if indexes:
            f.write(f"-- Indexes for {table_name}\n")
            for idx in indexes:
                f.write(f"-- {idx}\n")
        
        f.write("\n")

print("Schema exported to schema.sql")