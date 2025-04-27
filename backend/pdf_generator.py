"""
PDF Report Generator for Financial Advisor Platform

This module handles the generation of PDF reports for clients, accounts,
and performance metrics.
"""

import os
import pandas as pd
import numpy as np
from datetime import datetime
import tempfile
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
from reportlab.platypus import PageBreak, KeepTogether
from reportlab.graphics.shapes import Drawing
from reportlab.graphics.charts.piecharts import Pie
from reportlab.graphics.charts.linecharts import HorizontalLineChart
from reportlab.graphics.charts.barcharts import VerticalBarChart
from reportlab.graphics.charts.legends import Legend
from reportlab.lib.units import inch

# Make sure the reports directory exists
REPORTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'reports')
if not os.path.exists(REPORTS_DIR):
    os.makedirs(REPORTS_DIR)

def format_currency(value):
    """Format a value as currency with $ and commas"""
    return f"${value:,.2f}" if value is not None else "$0.00"

def format_percentage(value):
    """Format a value as a percentage with 2 decimal places"""
    return f"{value:.2f}%" if value is not None else "0.00%"

def get_report_styles():
    """
    Create and return a consistent set of styles for all reports
    
    Returns:
        ReportLab stylesheet with custom styles added
    """
    styles = getSampleStyleSheet()
    
    # Define custom styles only if they don't already exist
    if 'CustomTitle' not in styles:
        styles.add(ParagraphStyle(name='CustomTitle',
                                fontName='Helvetica-Bold',
                                fontSize=16,
                                alignment=1,
                                spaceAfter=12))
    
    if 'CustomHeading2' not in styles:
        styles.add(ParagraphStyle(name='CustomHeading2',
                                fontName='Helvetica-Bold',
                                fontSize=14,
                                spaceBefore=12,
                                spaceAfter=6))
    
    if 'CustomHeading3' not in styles:
        styles.add(ParagraphStyle(name='CustomHeading3',
                                fontName='Helvetica-Bold',
                                fontSize=12,
                                spaceBefore=8,
                                spaceAfter=4))
    
    if 'CustomNormal' not in styles:
        styles.add(ParagraphStyle(name='CustomNormal',
                                fontName='Helvetica',
                                fontSize=10,
                                spaceBefore=4,
                                spaceAfter=4))
    
    if 'CustomSmall' not in styles:
        styles.add(ParagraphStyle(name='CustomSmall',
                                fontName='Helvetica',
                                fontSize=8,
                                spaceBefore=2,
                                spaceAfter=2))
    
    return styles

def create_pie_chart(data, width=400, height=200):
    """
    Create a pie chart for asset allocation
    
    Args:
        data: Dictionary with asset types as keys and allocation percentages as values
        width, height: Dimensions of the chart
        
    Returns:
        A Drawing object containing the pie chart
    """
    drawing = Drawing(width, height)
    
    # Create the pie chart
    pie = Pie()
    pie.x = width // 2
    pie.y = height // 2
    pie.width = min(width, height) - 50
    pie.height = min(width, height) - 50
    pie.data = list(data.values())
    pie.labels = list(data.keys())
    
    # Set colors for the pie slices
    pie.slices.strokeWidth = 0.5
    colors_list = [colors.skyblue, colors.lightgreen, colors.salmon,
                  colors.lavender, colors.cornsilk, colors.pink, colors.lightgrey]
    for i, color in enumerate(colors_list[:len(data)]):
        pie.slices[i].fillColor = color
    
    # Add the pie chart to the drawing
    drawing.add(pie)
    
    # Create a legend
    legend = Legend()
    legend.alignment = 'right'
    legend.x = width - 10
    legend.y = height // 2
    legend.colorNamePairs = [(colors_list[i], (label, '%s' % format_percentage(value))) 
                           for i, (label, value) in enumerate(data.items())]
    legend.columnMaximum = 8
    legend.fontName = 'Helvetica'
    legend.fontSize = 8
    
    # Add the legend to the drawing
    drawing.add(legend)
    
    return drawing

def create_performance_chart(dates, values, title, width=500, height=250):
    """
    Create a line chart for performance over time
    
    Args:
        dates: List of dates
        values: List of corresponding values
        title: Chart title
        width, height: Dimensions of the chart
        
    Returns:
        A Drawing object containing the line chart
    """
    drawing = Drawing(width, height)
    
    # Create the line chart
    chart = HorizontalLineChart()
    chart.x = 50
    chart.y = 50
    chart.width = width - 100
    chart.height = height - 75
    chart.data = [values]
    chart.categoryAxis.categoryNames = dates
    
    # Configure the chart appearance
    chart.lineLabels.fontName = 'Helvetica'
    chart.lineLabels.fontSize = 8
    chart.categoryAxis.labels.fontName = 'Helvetica'
    chart.categoryAxis.labels.fontSize = 8
    chart.categoryAxis.labels.angle = 45
    chart.categoryAxis.labels.boxAnchor = 'ne'
    chart.valueAxis.labels.fontName = 'Helvetica'
    chart.valueAxis.labels.fontSize = 8
    chart.lines[0].strokeColor = colors.steelblue
    chart.lines[0].strokeWidth = 2
    
    # Format the value axis to show currency
    chart.valueAxis.labelTextFormat = lambda v: format_currency(v)
    
    # Add data labels to the chart
    for i, value in enumerate(values):
        chart.lineLabelArray[0][i] = format_currency(value)
    
    # Add the chart to the drawing
    drawing.add(chart)
    
    # Add a title
    title_style = ParagraphStyle('TitleStyle', fontName='Helvetica-Bold', fontSize=10, alignment=1)
    title_para = Paragraph(title, title_style)
    title_para.wrapOn(drawing, width, 20)
    title_para.drawOn(drawing, 0, height - 20)
    
    return drawing

def generate_client_summary_report(client_data, accounts_data, report_date=None):
    """
    Generate a PDF summary report for a client
    
    Args:
        client_data: Dictionary with client information
        accounts_data: List of dictionaries with account information
        report_date: Date to show on the report (defaults to today)
        
    Returns:
        Path to the generated PDF file
    """
    if report_date is None:
        report_date = datetime.now()
    
    # Create a temporary file for the PDF
    client_name = client_data.get('name', 'Client').replace(' ', '_')
    filename = f"{client_name}_Summary_{report_date.strftime('%Y%m%d')}.pdf"
    filepath = os.path.join(REPORTS_DIR, filename)
    
    # Create the PDF document
    doc = SimpleDocTemplate(filepath, pagesize=letter)
    styles = get_report_styles()
    
    # Create the elements list
    elements = []
    
    # Add title
    elements.append(Paragraph(f"Financial Summary Report", styles['CustomTitle']))
    elements.append(Paragraph(f"Generated: {report_date.strftime('%B %d, %Y')}", styles['CustomNormal']))
    elements.append(Spacer(1, 12))
    
    # Add client information
    elements.append(Paragraph("Client Information", styles['CustomHeading2']))
    
    client_info = [
        ["Name:", client_data.get('name', 'N/A')],
        ["Email:", client_data.get('email', 'N/A')],
        ["Phone:", client_data.get('phone', 'N/A')],
        ["Risk Profile:", client_data.get('risk_profile', 'N/A')],
        ["Segment:", client_data.get('segment', 'N/A')],
        ["Total Assets:", format_currency(client_data.get('total_assets', 0))]
    ]
    
    client_table = Table(client_info, colWidths=[100, 400])
    client_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    
    elements.append(client_table)
    elements.append(Spacer(1, 12))
    
    # Add account summary
    elements.append(Paragraph("Account Summary", styles['CustomHeading2']))
    
    # If no accounts, add a message
    if not accounts_data:
        elements.append(Paragraph("No accounts found for this client.", styles['CustomNormal']))
    else:
        # Create the account summary table
        account_header = ["Account Type", "Opening Date", "Current Balance", "Currency"]
        account_data = [account_header]
        
        total_balance = 0
        for account in accounts_data:
            opening_date = account.get('opening_date', '')
            if isinstance(opening_date, str):
                opening_date = datetime.strptime(opening_date, '%Y-%m-%dT%H:%M:%S') if opening_date else ''
            
            if opening_date:
                opening_date = opening_date.strftime('%Y-%m-%d')
            
            current_balance = account.get('current_balance', 0)
            total_balance += current_balance if current_balance else 0
            
            account_data.append([
                account.get('account_type', 'N/A'),
                opening_date,
                format_currency(current_balance),
                account.get('currency', 'USD')
            ])
        
        # Add total row
        account_data.append(['Total', '', format_currency(total_balance), ''])
        
        account_table = Table(account_data, colWidths=[120, 120, 120, 80])
        account_table.setStyle(TableStyle([
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),  # Header row bold
            ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),  # Total row bold
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
            ('BACKGROUND', (0, -1), (-1, -1), colors.lightgrey),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ALIGN', (2, 1), (2, -1), 'RIGHT'),  # Right-align numeric columns
        ]))
        
        elements.append(account_table)
        elements.append(Spacer(1, 12))
        
        # Add a page break
        elements.append(PageBreak())
        
        # Add individual account details
        elements.append(Paragraph("Account Details", styles['CustomHeading2']))
        
        for i, account in enumerate(accounts_data):
            account_type = account.get('account_type', 'Account')
            account_id = account.get('id', i+1)
            
            elements.append(Paragraph(f"{account_type} (ID: {account_id})", styles['CustomHeading3']))
            
            # Account details
            details = [
                ["Opening Date:", account.get('opening_date', 'N/A')],
                ["Current Balance:", format_currency(account.get('current_balance', 0))],
                ["Currency:", account.get('currency', 'USD')]
            ]
            
            details_table = Table(details, colWidths=[100, 400])
            details_table.setStyle(TableStyle([
                ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
                ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ]))
            
            elements.append(details_table)
            elements.append(Spacer(1, 12))
            
    # Build the PDF
    doc.build(elements)
    
    return filepath

def generate_account_performance_report(account_data, performance_data, activities_data=None, report_date=None):
    """
    Generate a PDF performance report for an account
    
    Args:
        account_data: Dictionary with account information
        performance_data: Dictionary with performance metrics
        activities_data: List of dictionaries with recent account activities
        report_date: Date to show on the report (defaults to today)
        
    Returns:
        Path to the generated PDF file
    """
    if report_date is None:
        report_date = datetime.now()
    
    # Create a temporary file for the PDF
    account_type = account_data.get('account_type', 'Account').replace(' ', '_')
    account_id = account_data.get('id', '0')
    filename = f"{account_type}_{account_id}_Performance_{report_date.strftime('%Y%m%d')}.pdf"
    filepath = os.path.join(REPORTS_DIR, filename)
    
    # Create the PDF document
    doc = SimpleDocTemplate(filepath, pagesize=letter)
    styles = get_report_styles()
    
    # Create the elements list
    elements = []
    
    # Add title
    account_type = account_data.get('account_type', 'Account')
    account_id = account_data.get('id', '')
    elements.append(Paragraph(f"Account Performance Report", styles['CustomTitle']))
    elements.append(Paragraph(f"{account_type} (ID: {account_id})", styles['CustomHeading3']))
    elements.append(Paragraph(f"Generated: {report_date.strftime('%B %d, %Y')}", styles['CustomNormal']))
    elements.append(Spacer(1, 12))
    
    # Add account information
    elements.append(Paragraph("Account Information", styles['CustomHeading2']))
    
    account_info = [
        ["Account Type:", account_data.get('account_type', 'N/A')],
        ["Opening Date:", account_data.get('opening_date', 'N/A')],
        ["Current Balance:", format_currency(account_data.get('current_balance', 0))],
        ["Currency:", account_data.get('currency', 'USD')]
    ]
    
    account_table = Table(account_info, colWidths=[120, 380])
    account_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    
    elements.append(account_table)
    elements.append(Spacer(1, 12))
    
    # Add performance metrics
    elements.append(Paragraph("Performance Metrics", styles['CustomHeading2']))
    
    if not performance_data or 'error' in performance_data:
        elements.append(Paragraph("No performance data available for this account.", styles['CustomNormal']))
    else:
        # Create the performance metrics table
        metrics = [
            ["YTD Return:", format_percentage(performance_data.get('ytd_return', 0))],
            ["1-Year Return:", format_percentage(performance_data.get('one_yr_return', 0))],
            ["3-Year Return (Annualized):", format_percentage(performance_data.get('three_yr_return', 0))],
            ["5-Year Return (Annualized):", format_percentage(performance_data.get('five_yr_return', 0))],
            ["Volatility:", format_percentage(performance_data.get('volatility', 0))],
            ["Maximum Drawdown:", format_percentage(performance_data.get('max_drawdown', 0))]
        ]
        
        metrics_table = Table(metrics, colWidths=[200, 300])
        metrics_table.setStyle(TableStyle([
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))
        
        elements.append(metrics_table)
        elements.append(Spacer(1, 12))
        
        # Add asset allocation pie chart
        if 'allocation' in performance_data and performance_data['allocation']:
            elements.append(Paragraph("Asset Allocation", styles['Heading2']))
            
            allocation_chart = create_pie_chart(performance_data['allocation'])
            elements.append(allocation_chart)
            elements.append(Spacer(1, 12))
    
    # Add recent activities if provided
    if activities_data:
        elements.append(PageBreak())
        elements.append(Paragraph("Recent Account Activities", styles['Heading2']))
        
        # Create the activities table
        activity_header = ["Date", "Type", "Description", "Amount"]
        activity_data = [activity_header]
        
        for activity in activities_data:
            activity_date = activity.get('date', '')
            if isinstance(activity_date, str):
                activity_date = datetime.strptime(activity_date, '%Y-%m-%dT%H:%M:%S') if activity_date else ''
            
            if activity_date:
                activity_date = activity_date.strftime('%Y-%m-%d')
            
            amount = activity.get('amount', 0)
            formatted_amount = format_currency(amount)
            
            activity_data.append([
                activity_date,
                activity.get('type', 'N/A'),
                activity.get('description', 'N/A'),
                formatted_amount
            ])
        
        activity_table = Table(activity_data, colWidths=[80, 80, 220, 100])
        activity_table.setStyle(TableStyle([
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),  # Header row bold
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ALIGN', (3, 1), (3, -1), 'RIGHT'),  # Right-align amount column
        ]))
        
        elements.append(activity_table)
    
    # Build the PDF
    doc.build(elements)
    
    return filepath