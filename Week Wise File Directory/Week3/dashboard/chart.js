const socket = io();
const ctx = document.getElementById('fusionChart').getContext('2d');

const chart = new Chart(ctx, {
  type: 'line',
  data: {
    labels: [],
    datasets: [
      {
        label: 'Fusion Output',
        data: [],
        borderColor: 'blue',
        fill: false,
      },
      {
        label: 'Model Output',
        data: [],
        borderColor: 'green',
        fill: false,
      }
    ]
  },
  options: {
    animation: false,
    responsive: true,
    scales: {
      x: { title: { display: true, text: 'Time' }},
      y: { title: { display: true, text: 'Value' }}
    }
  }
});

socket.on('new_data', function(data) {
  chart.data.labels.push(data.timestamp);
  chart.data.datasets[0].data.push(data.fusion_value);
  chart.data.datasets[1].data.push(data.model_value);

  if (chart.data.labels.length > 50) {
    chart.data.labels.shift();
    chart.data.datasets[0].data.shift();
    chart.data.datasets[1].data.shift();
  }

  chart.update();
});
