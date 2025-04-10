const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/auth');
const itemRoutes = require('./routes/items');

const app = express();
app.use(express.json());

mongoose.connect('mongodb://localhost/quickpass', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.log(err));

app.use('/api/auth', authRoutes);
app.use('/api/items', itemRoutes);

app.listen(3000, () => console.log('Server running on port 3000'));