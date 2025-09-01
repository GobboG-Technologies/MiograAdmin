const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

// Initialize Firebase Admin SDK (only once)
if (!admin.apps.length) {
  admin.initializeApp();
}

// Upload Product Image Function - Gen 2
exports.uploadProductImage = onRequest(
  {
    region: 'us-central1',
    memory: '256MiB',
    timeoutSeconds: 540,
    maxInstances: 10
  },
  async (req, res) => {
    return cors(req, res, async () => {
      // Set CORS headers explicitly
      res.set('Access-Control-Allow-Origin', '*');
      res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      res.set('Access-Control-Allow-Headers', 'Content-Type');

      // Handle preflight OPTIONS request
      if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
      }

      console.log("📤 Upload request received");
      console.log("Method:", req.method);
      console.log("Headers:", req.headers);

      try {
        // Only allow POST
        if (req.method !== "POST") {
          console.log("❌ Method not allowed:", req.method);
          return res.status(405).json({
            success: false,
            error: "Method not allowed. Use POST.",
          });
        }

        // Log request body info (without the actual image data)
        console.log("Request body keys:", Object.keys(req.body || {}));

        // Extract data from request
        const { imageBase64, fileName, productId } = req.body;

        // Enhanced validation
        if (!imageBase64) {
          console.log("❌ No image data provided");
          return res.status(400).json({
            success: false,
            error: "No image data provided",
          });
        }

        if (typeof imageBase64 !== 'string') {
          console.log("❌ Invalid image data type");
          return res.status(400).json({
            success: false,
            error: "Image data must be a base64 string",
          });
        }

        if (!fileName) {
          console.log("❌ No filename provided");
          return res.status(400).json({
            success: false,
            error: "No filename provided",
          });
        }

        console.log("📋 Processing upload for:", fileName);
        console.log("📊 Base64 length:", imageBase64.length);

        // Clean base64 string (remove data URL prefix if present)
        let cleanBase64 = imageBase64;
        if (imageBase64.includes(',')) {
          cleanBase64 = imageBase64.split(',')[1];
          console.log("🧹 Cleaned base64 prefix");
        }

        // Convert base64 to buffer with error handling
        let imageBuffer;
        try {
          imageBuffer = Buffer.from(cleanBase64, "base64");
          console.log("✅ Buffer created, size:", imageBuffer.length);
        } catch (bufferError) {
          console.log("❌ Buffer creation failed:", bufferError.message);
          return res.status(400).json({
            success: false,
            error: "Invalid base64 image data",
            details: bufferError.message,
          });
        }

        // Check file size (5MB limit)
        const maxSize = 5 * 1024 * 1024;
        if (imageBuffer.length > maxSize) {
          const sizeInMB = (imageBuffer.length / 1024 / 1024).toFixed(2);
          console.log(`❌ Image too large: ${sizeInMB}MB`);
          return res.status(400).json({
            success: false,
            error: `Image too large. Max size is 5MB, received ${sizeInMB}MB`,
          });
        }

        // Generate unique filename with timestamp
        const timestamp = Date.now();
        const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
        const finalFileName = `product_${timestamp}_${sanitizedFileName}`;
        const filePath = `products/${finalFileName}`;

        console.log("📁 Upload path:", filePath);

        // Get storage bucket with error handling
        let bucket;
        try {
          bucket = admin.storage().bucket();
          console.log("✅ Storage bucket obtained");
        } catch (storageError) {
          console.log("❌ Storage bucket error:", storageError.message);
          return res.status(500).json({
            success: false,
            error: "Storage service unavailable",
            details: storageError.message,
          });
        }

        const file = bucket.file(filePath);

        // Upload to Firebase Storage with enhanced options
        try {
          console.log("⬆️ Starting upload...");

          await file.save(imageBuffer, {
            metadata: {
              contentType: "image/jpeg",
              cacheControl: "public, max-age=3600",
              metadata: {
                uploadedAt: new Date().toISOString(),
                productId: productId || "",
                originalFileName: fileName,
                platform: "desktop-cloud-function"
              },
            },
            public: false, // Don't make public immediately
            validation: false,
            resumable: false, // Use simple upload for smaller files
          });

          console.log("✅ File uploaded successfully");

          // Make file publicly accessible
          await file.makePublic();
          console.log("✅ File made public");

        } catch (uploadError) {
          console.log("❌ Upload failed:", uploadError.message);
          console.log("📚 Upload error details:", uploadError);

          return res.status(500).json({
            success: false,
            error: "File upload failed",
            details: uploadError.message,
          });
        }

        // Generate public URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
        console.log("🌐 Generated URL:", publicUrl);

        // If productId provided, update Firestore
        if (productId && productId.trim() !== '') {
          try {
            await admin
              .firestore()
              .collection("products")
              .doc(productId)
              .update({
                imageUrl: publicUrl,
                imageUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
                uploadMethod: 'cloud-function'
              });
            console.log(`✅ Updated product ${productId} with image URL`);
          } catch (firestoreError) {
            console.log("⚠️ Firestore update failed:", firestoreError.message);
            // Don't fail the entire request if Firestore update fails
          }
        }

        // Return success response
        const response = {
          success: true,
          url: publicUrl,
          fileName: finalFileName,
          size: imageBuffer.length,
          sizeFormatted: `${(imageBuffer.length / 1024).toFixed(1)} KB`,
          message: "Image uploaded successfully",
          timestamp: new Date().toISOString()
        };

        console.log("🎉 Upload completed successfully");
        return res.status(200).json(response);

      } catch (error) {
        console.log("❌ Unexpected error:", error);
        console.log("📚 Error stack:", error.stack);

        return res.status(500).json({
          success: false,
          error: "Upload failed due to server error",
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    });
  }
);

// Health check endpoint - Gen 2
exports.healthCheck = onRequest((req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    message: 'Cloud function is running'
  });
});

// Cleanup old images every 24 hours - Gen 2
exports.cleanupOldImages = onSchedule(
  {
    schedule: "every 24 hours",
    region: 'us-central1',
    memory: '256MiB'
  },
  async (event) => {
    console.log("🧹 Starting image cleanup task");

    try {
      const bucket = admin.storage().bucket();
      const [files] = await bucket.getFiles({
        prefix: "products/",
      });

      console.log(`Found ${files.length} files to check`);

      const thirtyDaysAgo = Date.now() - 30 * 24 * 60 * 60 * 1000;
      let deletedCount = 0;

      for (const file of files) {
        try {
          const [metadata] = await file.getMetadata();
          const createdTime = new Date(metadata.timeCreated).getTime();

          // Delete files older than 30 days that aren't linked to products
          if (createdTime < thirtyDaysAgo) {
            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;

            const productsSnapshot = await admin
              .firestore()
              .collection("products")
              .where("imageUrl", "==", publicUrl)
              .limit(1)
              .get();

            if (productsSnapshot.empty) {
              await file.delete();
              console.log(`Deleted old unused image: ${file.name}`);
              deletedCount++;
            }
          }
        } catch (fileError) {
          console.log(`Error processing file ${file.name}:`, fileError.message);
        }
      }

      console.log(`🗑️ Cleanup completed. Deleted ${deletedCount} unused images`);
      return { deletedCount, totalChecked: files.length };

    } catch (error) {
      console.error("❌ Cleanup task failed:", error);
      throw error;
    }
  }
);