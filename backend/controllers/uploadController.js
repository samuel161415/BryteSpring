const AWS = require('aws-sdk');
const multer = require('multer');
const { v4: uuidv4 } = require('../utils/uuid');
const path = require('path');

// Configure DigitalOcean Spaces (S3-compatible)
const s3 = new AWS.S3({
  endpoint: process.env.DO_SPACES_ENDPOINT,
  accessKeyId: process.env.DO_SPACES_ACCESS_KEY,
  secretAccessKey: process.env.DO_SPACES_SECRET_KEY,
  region: process.env.DO_SPACES_REGION,
  s3ForcePathStyle: false
});

const BUCKET_NAME = process.env.DO_SPACES_BUCKET_NAME;

// Helper function to sanitize metadata values for S3
const sanitizeMetadata = (value) => {
  if (!value) return '';
  return value
    .toString()
    .replace(/[^\x20-\x7E]/g, '') // Remove non-ASCII characters
    .replace(/[\r\n\t]/g, ' ') // Replace newlines and tabs with spaces
    .trim()
    .substring(0, 1024); // Limit length for metadata
};

// Configure multer for memory storage
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB limit
  },
  fileFilter: (req, file, cb) => {
    // Allow common file types
    const allowedTypes = [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
      'application/pdf',
      'text/plain',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'video/mp4',
      'audio/mpeg',
      'audio/wav'
    ];

    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only images, documents, videos, and audio files are allowed.'), false);
    }
  }
});

// Upload single file
exports.uploadSingle = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const file = req.file;
    const { verse_id, folder_path = '' } = req.body;
    const userId = req.user._id;

    // Generate unique filename
    const fileExtension = path.extname(file.originalname);
    const fileName = `${uuidv4()}${fileExtension}`;
    
    // Create file path with verse_id and optional folder_path
    const filePath = verse_id ? 
      `verses/${verse_id}/${folder_path ? folder_path + '/' : ''}${fileName}` :
      `uploads/${folder_path ? folder_path + '/' : ''}${fileName}`;

    // Upload to DigitalOcean Spaces
    const uploadParams = {
      Bucket: BUCKET_NAME,
      Key: filePath,
      Body: file.buffer,
      ContentType: file.mimetype,
      ACL: 'public-read', // Make file publicly accessible
      Metadata: {
        originalName: sanitizeMetadata(file.originalname),
        uploadedBy: sanitizeMetadata(userId.toString()),
        uploadedAt: sanitizeMetadata(new Date().toISOString()),
        verseId: sanitizeMetadata(verse_id || 'none')
      }
    };

    const result = await s3.upload(uploadParams).promise();

    // Return file information
    const fileInfo = {
      id: uuidv4(),
      originalName: file.originalname,
      fileName: fileName,
      filePath: filePath,
      url: result.Location,
      cdnUrl: `${process.env.DO_SPACES_CDN_ENDPOINT}/${filePath}`,
      size: file.size,
      mimeType: file.mimetype,
      verse_id: verse_id || null,
      uploaded_by: userId,
      uploaded_at: new Date(),
      folder_path: folder_path || null
    };

    res.status(200).json({
      message: 'File uploaded successfully',
      file: fileInfo
    });

  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).json({ 
      message: 'Error uploading file', 
      error: error.message 
    });
  }
};

// Upload multiple files
exports.uploadMultiple = async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No files uploaded' });
    }

    const files = req.files;
    const { verse_id, folder_path = '' } = req.body;
    const userId = req.user._id;

    const uploadPromises = files.map(async (file) => {
      // Generate unique filename
      const fileExtension = path.extname(file.originalname);
      const fileName = `${uuidv4()}${fileExtension}`;
      
      // Create file path
      const filePath = verse_id ? 
        `verses/${verse_id}/${folder_path ? folder_path + '/' : ''}${fileName}` :
        `uploads/${folder_path ? folder_path + '/' : ''}${fileName}`;

      // Upload to DigitalOcean Spaces
      const uploadParams = {
        Bucket: BUCKET_NAME,
        Key: filePath,
        Body: file.buffer,
        ContentType: file.mimetype,
        ACL: 'public-read',
        Metadata: {
          originalName: sanitizeMetadata(file.originalname),
          uploadedBy: sanitizeMetadata(userId.toString()),
          uploadedAt: sanitizeMetadata(new Date().toISOString()),
          verseId: sanitizeMetadata(verse_id || 'none')
        }
      };

      const result = await s3.upload(uploadParams).promise();

      return {
        id: uuidv4(),
        originalName: file.originalname,
        fileName: fileName,
        filePath: filePath,
        url: result.Location,
        cdnUrl: `${process.env.DO_SPACES_CDN_ENDPOINT}/${filePath}`,
        size: file.size,
        mimeType: file.mimetype,
        verse_id: verse_id || null,
        uploaded_by: userId,
        uploaded_at: new Date(),
        folder_path: folder_path || null
      };
    });

    const uploadedFiles = await Promise.all(uploadPromises);

    res.status(200).json({
      message: `${uploadedFiles.length} files uploaded successfully`,
      files: uploadedFiles
    });

  } catch (error) {
    console.error('Error uploading files:', error);
    res.status(500).json({ 
      message: 'Error uploading files', 
      error: error.message 
    });
  }
};

// Delete file
exports.deleteFile = async (req, res) => {
  try {
    // Get the file path from query parameter
    const { filePath } = req.query;
    const userId = req.user._id;

    if (!filePath) {
      return res.status(400).json({ message: 'File path is required' });
    }

    // Decode the file path (in case it's URL encoded)
    const decodedFilePath = decodeURIComponent(filePath);

    // Delete from DigitalOcean Spaces
    const deleteParams = {
      Bucket: BUCKET_NAME,
      Key: decodedFilePath
    };

    await s3.deleteObject(deleteParams).promise();

    res.status(200).json({
      message: 'File deleted successfully',
      filePath: decodedFilePath
    });

  } catch (error) {
    console.error('Error deleting file:', error);
    res.status(500).json({ 
      message: 'Error deleting file', 
      error: error.message 
    });
  }
};

// Get file info (list files in a verse or folder)
exports.listFiles = async (req, res) => {
  try {
    const { verse_id, folder_path = '', prefix = '' } = req.query;
    const userId = req.user._id;

    // Build the prefix for listing
    let listPrefix = '';
    if (verse_id) {
      listPrefix = `verses/${verse_id}/`;
      if (folder_path) {
        listPrefix += `${folder_path}/`;
      }
    } else {
      listPrefix = 'uploads/';
      if (folder_path) {
        listPrefix += `${folder_path}/`;
      }
    }

    if (prefix) {
      listPrefix += prefix;
    }

    const listParams = {
      Bucket: BUCKET_NAME,
      Prefix: listPrefix,
      MaxKeys: 100 // Limit results
    };

    const result = await s3.listObjectsV2(listParams).promise();

    const files = result.Contents.map(item => ({
      key: item.Key,
      fileName: item.Key.split('/').pop(),
      size: item.Size,
      lastModified: item.LastModified,
      url: `${process.env.DO_SPACES_ENDPOINT}/${item.Key}`,
      cdnUrl: `${process.env.DO_SPACES_CDN_ENDPOINT}/${item.Key}`
    }));

    res.status(200).json({
      message: 'Files retrieved successfully',
      files: files,
      count: files.length,
      prefix: listPrefix
    });

  } catch (error) {
    console.error('Error listing files:', error);
    res.status(500).json({ 
      message: 'Error listing files', 
      error: error.message 
    });
  }
};

// Export multer middleware for use in routes
exports.uploadMiddleware = upload;
