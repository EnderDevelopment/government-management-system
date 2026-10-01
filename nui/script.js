document.addEventListener('DOMContentLoaded', function() {
    const departmentSelect = document.getElementById('department');
    const rankSelect = document.getElementById('rank');
    const applyButton = document.getElementById('apply');
    const closeButton = document.getElementById('close');
    const licensesList = document.getElementById('licenses');
    const applicationsList = document.getElementById('applications');
    const employeesList = document.getElementById('employees');

    applyButton.addEventListener('click', function() {
        const department = departmentSelect.value;
        const rank = rankSelect.value;
        fetch('https://government/apply', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ type: department })
        }).then(resp => resp.json()).then(resp => console.log(resp));
    });

    closeButton.addEventListener('click', function() {
        fetch('https://government/close', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(resp => console.log(resp));
    });

    function loadLicenses() {
        fetch('https://government/getLicenses', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(licenses => {
            licensesList.innerHTML = '<h2>Licenses</h2>';
            licenses.forEach(license => {
                const listItem = document.createElement('div');
                listItem.className = 'list-item';
                listItem.textContent = license;
                licensesList.appendChild(listItem);
            });
        });
    }

    function loadApplications() {
        fetch('https://government/getApplications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(applications => {
            applicationsList.innerHTML = '<h2>Applications</h2>';
            applications.forEach(application => {
                const listItem = document.createElement('div');
                listItem.className = 'list-item';
                listItem.textContent = `${application.type} - ${application.status}`;
                applicationsList.appendChild(listItem);
            });
        });
    }

    function loadEmployees() {
        const department = departmentSelect.value;
        fetch('https://government/getEmployees', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ department: department })
        }).then(resp => resp.json()).then(employees => {
            employeesList.innerHTML = '<h2>Employees</h2>';
            employees.forEach(employee => {
                const listItem = document.createElement('div');
                listItem.className = 'list-item';
                listItem.textContent = `${employee.identifier} - ${employee.rank}`;
                employeesList.appendChild(listItem);
            });
        });
    }

    departmentSelect.addEventListener('change', loadEmployees);

    loadLicenses();
    loadApplications();
    loadEmployees();
});