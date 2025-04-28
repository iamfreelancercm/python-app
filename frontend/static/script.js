
// API endpoints
const API_BASE_URL = 'http://20.186.57.72:8000/api';

// Load households when page loads
document.addEventListener('DOMContentLoaded', loadHouseholds);

// Handle file upload
document.getElementById('uploadForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const file = document.getElementById('excelFile').files[0];
    if (!file) {
        alert('Please select a file');
        return;
    }

    const formData = new FormData();
    formData.append('file', file);

    try {
        const response = await fetch(`${API_BASE_URL}/import/excel`, {
            method: 'POST',
            body: formData
        });
        const data = await response.json();
        if (response.ok) {
            alert('File uploaded successfully');
            loadHouseholds();
        } else {
            alert(`Error: ${data.error}`);
        }
    } catch (error) {
        alert('Error uploading file');
    }
});

// Handle sample data creation
document.getElementById('createSampleData').addEventListener('click', async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/create-sample-data`, {
            method: 'POST'
        });
        const data = await response.json();
        if (response.ok) {
            alert('Sample data created successfully');
            loadHouseholds();
        } else {
            alert(`Error: ${data.error}`);
        }
    } catch (error) {
        alert('Error creating sample data');
    }
});

// Load households
async function loadHouseholds() {
    try {
        const response = await fetch(`${API_BASE_URL}/households`);
        const households = await response.json();
        
        const tbody = document.querySelector('#householdsTable tbody');
        tbody.innerHTML = '';
        
        households.forEach(household => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${household.name}</td>
                <td>${household.email}</td>
                <td>${household.phone}</td>
                <td>${household.risk_profile}</td>
                <td>
                    <button class="btn btn-sm btn-primary" onclick="viewAccounts(${household.id})">
                        View Accounts
                    </button>
                </td>
            `;
            tbody.appendChild(row);
        });
    } catch (error) {
        alert('Error loading households');
    }
}

// View accounts for a household
async function viewAccounts(householdId) {
    try {
        const response = await fetch(`${API_BASE_URL}/households/${householdId}/accounts`);
        const accounts = await response.json();
        // You can implement the accounts view functionality here
        console.log(accounts);
    } catch (error) {
        alert('Error loading accounts');
    }
}

