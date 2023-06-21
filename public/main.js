document.getElementById('fileInput').addEventListener('change', async (event) => {
    const file = event.target.files[0];
    const formData = new FormData();
    formData.append('excelFile', file);

    const response = await fetch('/upload', {method: 'POST', body: formData});
    const data = await response.json();
    console.log('data ', data)
    const ctx = document.getElementById('myChart').getContext('2d');
    const myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map((_, i) => `Data ${i + 1}`),
            datasets: [{
                label: 'Excel Data',
                data: data,
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
            }]
        }
    });
});
