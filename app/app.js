const express = require('express');
const os = require('os');

const app = express();
const startTime = Date.now();

app.get('/', (req, res) => {
    res.send('Hello, World!');
});

app.get('/health-check', (req, res) => {
    const uptime = Date.now() - startTime;
     res.json({ uptime: `${uptime}ms` });
});

const PORT = process.env.PORT || 3333;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});