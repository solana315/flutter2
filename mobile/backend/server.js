const express = require('express');
const app = express();
const port = 4000;

app.set('port', port);

app.use(express.json());

const appointmentsRoutes = require('./routes/appointementRoutes');
const authRoute = require('./routes/authRoute');

app.use('/appointments', appointmentsRoutes);
app.use('/auth', authRoute);

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
