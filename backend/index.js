require('dotenv').config();
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Import routes
const indexRouter = require('./routes');

// Middleware
app.use(express.json());

// Routes
app.use('/', indexRouter);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something went wrong!');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
