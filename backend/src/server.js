// backend/src/server.js
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv'); // Import dotenv untuk membaca .env
const path = require('path');
const { connectDb } = require('./config/db'); // Import fungsi koneksi DB
const authRoutes = require('./routes/authRoutes');
const adminRoutes = require('./routes/adminRoutes');
const guruRoutes = require('./routes/guruRoutes');
const excelRoutes = require('./routes/excelRoutes');
const gradeRoutes = require('./routes/gradeRoutes');
const kkmRoutes = require('./routes/kkmRoutes');
const analyticsRoutes = require('./routes/analyticsRoutes');

// Muat variabel lingkungan dari file .env
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000; // Gunakan port dari .env atau default 5000
const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:3000';

// ===============================
// TRUST PROXY (untuk Railway)
// ===============================
// Railway menggunakan reverse proxy, harus trust proxy untuk rate limiter
if (process.env.NODE_ENV === 'production') {
  app.set('trust proxy', 1); // Trust first proxy
}

// ===============================
// SECURITY MIDDLEWARE
// ===============================

// 1. Helmet - Set security HTTP headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'", "https://cdnjs.cloudflare.com"], // Allow inline scripts for React + FontAwesome CDN
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com", "https://cdnjs.cloudflare.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com", "https://cdnjs.cloudflare.com", "data:"],
      imgSrc: ["'self'", "data:", "https:", "blob:"],
      connectSrc: ["'self'", "http://localhost:5000", "http://localhost:3000"],
      frameSrc: ["'none'"],
      objectSrc: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
      frameAncestors: ["'none'"],
      upgradeInsecureRequests: process.env.NODE_ENV === 'production' ? [] : null
    }
  },
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// 2. CORS - Configure properly untuk specific origin
// In production, if frontend is served from same domain, allow same origin
// In development, allow localhost:3000
const corsOptions = {
  origin: process.env.NODE_ENV === 'production'
    ? [FRONTEND_URL, 'https://*.railway.app'] // Allow Railway domains
    : ['http://localhost:3000', 'http://localhost:3001'], // Development
  credentials: true,
  exposedHeaders: ['Content-Disposition']
};

app.use(cors(corsOptions));

// 3. Rate Limiting - Prevent brute force attacks
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 500, // Limit each IP to 500 requests per windowMs (development)
  message: {
    error: 'Too many requests',
    message: 'Anda telah mencapai batas request. Silakan tunggu beberapa saat sebelum mencoba lagi.',
    retryAfter: '15 menit'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    console.log(`⚠️  Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      error: 'Too many requests',
      message: 'Anda telah mencapai batas request. Silakan tunggu beberapa saat sebelum mencoba lagi.',
      retryAfter: '15 menit'
    });
  }
});

// Apply rate limiting to all routes
app.use(limiter);

// Additional Security Headers to fix ZAP warnings
app.use((req, res, next) => {
  // X-Content-Type-Options
  res.setHeader('X-Content-Type-Options', 'nosniff');
  
  // X-Frame-Options (Anti-clickjacking)
  res.setHeader('X-Frame-Options', 'DENY');
  
  // Permissions-Policy
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  
  // Remove Server header (hide version info)
  res.removeHeader('X-Powered-By');
  
  // Cache-Control for sensitive pages
  if (req.path.includes('/api/')) {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
  }
  
  next();
});

// Stricter rate limit for auth routes
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 login requests per windowMs
  message: 'Too many login attempts, please try again after 15 minutes.',
  skipSuccessfulRequests: true // Don't count successful requests
});

// 4. Additional Security Headers
app.use((req, res, next) => {
  // Anti-clickjacking
  res.setHeader('X-Frame-Options', 'DENY');
  
  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');
  
  // Permissions Policy (formerly Feature-Policy)
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  
  // Remove server version info
  res.removeHeader('X-Powered-By');
  
  // Referrer Policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Cross-Origin Policies for Spectre protection
  res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
  res.setHeader('Cross-Origin-Resource-Policy', 'same-origin');
  res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
  
  next();
});

// 5. Body parser with size limits
app.use(express.json({ limit: '10mb' })); // Limit request body size
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Koneksi ke database saat aplikasi dimulai
connectDb();

// ===============================
// ROUTES
// ===============================

// Auth routes with stricter rate limiting
app.use('/api/auth', authLimiter, authRoutes);

// Protected routes (will add auth middleware in routes files)
app.use('/api/admin', adminRoutes);
app.use('/api/guru', guruRoutes);
app.use('/api/excel', excelRoutes);
app.use('/api/grades', gradeRoutes);
app.use('/api/kkm', kkmRoutes);
app.use('/api/analytics', analyticsRoutes);

// Health check endpoint (before static files)
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes check
app.get('/api', (req, res) => {
  res.json({
    message: 'API Sistem Manajemen Akademik Berjalan!',
    version: '1.0.0',
    security: 'hardened',
    status: 'healthy'
  });
});

// ===============================
// SERVE FRONTEND IN PRODUCTION
// ===============================
if (process.env.NODE_ENV === 'production') {
  // Serve static files from React build
  const frontendBuildPath = path.join(__dirname, '../../frontend/build');
  app.use(express.static(frontendBuildPath));

  // Handle React routing - return index.html for all non-API routes
  app.get('*', (req, res) => {
    // Skip if it's an API route
    if (req.path.startsWith('/api/')) {
      return res.status(404).json({ message: 'API endpoint not found' });
    }
    res.sendFile(path.join(frontendBuildPath, 'index.html'));
  });
} else {
  // Development mode - just return API info
  app.get('/', (req, res) => {
    res.json({
      message: 'API Sistem Manajemen Akademik Berjalan!',
      version: '1.0.0',
      security: 'hardened',
      status: 'healthy',
      mode: 'development'
    });
  });

  // 404 handler for development
  app.use((req, res) => {
    res.status(404).json({ message: 'Endpoint not found' });
  });
}

// Error handler
app.use((err, req, res, _next) => {
  console.error('Error:', err.stack);
  res.status(err.status || 500).json({
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`\n🚀 Server berjalan di http://localhost:${PORT}`);
  console.log('🔒 Security: ENABLED (Helmet, Rate Limit, CORS)');
  console.log(`🌐 Frontend URL: ${FRONTEND_URL}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}\n`);
});
