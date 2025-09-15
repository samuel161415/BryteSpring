require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

// Import DB connection
const { connectToDatabase } = require('./db/connection');

// Import routes
const indexRouter = require('./routes');
const verseRouter = require('./routes/verse');
const invitationRouter = require('./routes/invitation');
const channelRouter = require('./routes/channel');
const dashboardRouter = require('./routes/dashboard');

// CORS configuration


const corsOptions = {
  origin: true, // ✅ Allow ALL origins
  credentials: true, // ✅ Allow cookies and authorization headers
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Origin', 'X-Requested-With', 'Content-Type', 'Accept', 'Authorization'],
  exposedHeaders: ['Authorization'],
  optionsSuccessStatus: 200
};

// Apply CORS middleware
app.use(cors(corsOptions));

// Middleware
app.use(express.json());

// Routes
app.use('/', indexRouter);
app.use('/verse', verseRouter);
app.use('/invitation', invitationRouter);
app.use('/channel', channelRouter);
app.use('/dashboard', dashboardRouter);

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
