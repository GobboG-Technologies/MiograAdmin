// Import new modular APIs
const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

// Initialize Firebase Admin SDK
admin.initializeApp();

// Upload Product Image Function
exports.uploadProductImage = onRequest(
  { memory: "512MiB", timeoutSeconds: 60 },
  async (req, res) => {
    return cors(req, res, async () => {
      console.log("Upload request received");

      try {
        // Only allow POST
        if (req.method !== "POST") {
          return res.status(405).json({
            success: false,
            error: "Method not allowed. Use POST.",
          });
        }

        // Extract data from request
        const { imageBase64, fileName, productId } = req.body;

        // Validation
        if (!imageBase64) {
          return res.status(400).json({
            success: false,
            error: "No image data provided",
          });
        }

        if (!fileName) {
          return res.status(400).json({
            success: false,
            error: "No filename provided",
          });
        }

        // Convert base64 to buffer
        const imageBuffer = Buffer.from(imageBase64, "base64");

        // Check file size (5MB limit)
        const maxSize = 5 * 1024 * 1024;
        if (imageBuffer.length > maxSize) {
          const sizeInMB = (imageBuffer.length / 1024 / 1024).toFixed(2);
          return res.status(400).json({
            success: false,
            error: `Image too large. Max size is 5MB, received ${sizeInMB}MB`,
          });
        }

        // Generate unique filename if not provided
        const timestamp = Date.now();
        const finalFileName = fileName || `product_${timestamp}.jpg`;
        const filePath = `products/${finalFileName}`;

        // Get storage bucket
        const bucket = admin.storage().bucket();
        const file = bucket.file(filePath);

        // Upload to Firebase Storage
        await file.save(imageBuffer, {
          metadata: {
            contentType: "image/jpeg",
            metadata: {
              uploadedAt: new Date().toISOString(),
              productId: productId || "",
            },
          },
          public: true,
          validation: false,
        });

        // Make file publicly accessible
        await file.makePublic();

        // Generate public URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;

        console.log(`Upload successful: ${publicUrl}`);

        // If productId provided, update Firestore
        if (productId) {
          try {
            await admin
              .firestore()
              .collection("products")
              .doc(productId)
              .update({
                imageUrl: publicUrl,
                imageUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
              });
            console.log(`Updated product ${productId} with image URL`);
          } catch (firestoreError) {
            console.error("Firestore update failed:", firestoreError);
          }
        }

        // Return success response
        return res.status(200).json({
          success: true,
          url: publicUrl,
          fileName: finalFileName,
          size: imageBuffer.length,
          message: "Image uploaded successfully",
        });
      } catch (error) {
        console.error("Upload error:", error);
        return res.status(500).json({
          success: false,
          error: "Upload failed",
          details: error.message,
        });
      }
    });
  }
);

// Cleanup old images every 24 hours
exports.cleanupOldImages = onSchedule("every 24 hours", async (context) => {
  const bucket = admin.storage().bucket();
  const [files] = await bucket.getFiles({
    prefix: "products/",
  });

  const thirtyDaysAgo = Date.now() - 30 * 24 * 60 * 60 * 1000;

  for (const file of files) {
    const [metadata] = await file.getMetadata();
    const createdTime = new Date(metadata.timeCreated).getTime();

    // Delete files older than 30 days that aren't linked to products
    if (createdTime < thirtyDaysAgo) {
      const productsSnapshot = await admin
        .firestore()
        .collection("products")
        .where(
          "imageUrl",
          "==",
          `https://storage.googleapis.com/${bucket.name}/${file.name}`
        )
        .limit(1)
        .get();

      if (productsSnapshot.empty) {
        await file.delete();
        console.log(`Deleted old unused image: ${file.name}`);
      }
    }
  }

  return null;
});
