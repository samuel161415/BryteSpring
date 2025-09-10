require('dotenv').config();
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Import DB connection
const { connectToDatabase } = require('./db/connection');

// Import routes
const indexRouter = require('./routes');
const verseRouter = require('./routes/verse');
const invitationRouter = require('./routes/invitation');

// Middleware
app.use(express.json());

// Routes
app.use('/', indexRouter);
app.use('/verse', verseRouter);
app.use('/invitation', invitationRouter);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something went wrong!');
});

// Start server after DB is connected
connectToDatabase()
  .then(() => {
    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}`);
    });
  })
  .catch((error) => {
    console.error('Failed to start server due to DB connection error:', error.message);
    process.exit(1);
  });
