#!/usr/bin/env npx ts-node

import { 
  buildQueryCommandInput, 
  dynamoQueryIterator, 
  updateDynamoItem 
} from "@dfinitiv/constructs/lambda/dynamodb";

const TABLE_NAME = "MediaStack-MediaTable1D549DC8-Q32NKCEKYNY7";

// Set the TABLE_NAME env var for the Dfinitiv constructs
process.env.TABLE_NAME = TABLE_NAME;

async function migrateMarketingAssets() {
  console.log("Starting migration of marketing assets...");
  
  let totalMigrated = 0;
  let totalScanned = 0;

  // Query for all items with pk starting with "MARKETING"
  // We need to query each known PK pattern since we can't do a begins_with on PK in a query
  const pkPattern = "MARKETING#web#guide"; // Based on our analysis, all current assets have this PK
  
  const query = buildQueryCommandInput({
    keyFilter: [
      { attribute: "pk", operator: "=" as const, value: pkPattern },
    ],
  });

  console.log(`Querying for assets with pk: ${pkPattern}`);
  
  for await (const item of dynamoQueryIterator({ query })) {
    totalScanned++;
    
    try {
      // Determine content type based on existing data
      const contentType = item.assetType || "guide"; // Current data has assetType = "guide"
      const contentId = item.identifier || item.campaignId || "unknown";
      const sanitizedAssetName = item.sanitizedAssetName || item.assetName;
      
      console.log(`Migrating: ${contentType}/${contentId}/${item.assetName}`);
      
      // Build attributes to set
      const attributesToSet: Record<string, any> = {
        // Update GSI keys
        gsi1pk: "MARKETING",
        gsi1sk: `${contentType}#${contentId}#${sanitizedAssetName}`,
        gsi2pk: `MARKETING#${contentType}#${contentId}`,
        gsi2sk: `${item.mediaType || "IMAGE"}#${sanitizedAssetName}`,
        
        // Add new fields
        contentType: contentType,
        contentId: contentId,
        mediaType: item.mediaType || "IMAGE",
        
        // Update timestamp
        updatedAt: new Date().toISOString()
      };
      
      // Build attributes to delete (old fields)
      const attributesToDelete: string[] = [];
      if (item.category !== undefined) attributesToDelete.push("category");
      if (item.assetType !== undefined) attributesToDelete.push("assetType");
      if (item.identifier !== undefined) attributesToDelete.push("identifier");
      
      await updateDynamoItem({
        Key: {
          pk: item.pk,
          sk: item.sk
        },
        attributesToSet,
        attributesToDelete: attributesToDelete.length > 0 ? attributesToDelete : undefined
      });
      
      totalMigrated++;
      console.log(`✓ Migrated asset: ${item.pk} / ${item.sk}`);
    } catch (error) {
      console.error(`✗ Failed to migrate asset ${item.pk} / ${item.sk}:`, error);
    }
  }

  console.log(`\nMigration complete!`);
  console.log(`Total scanned: ${totalScanned}`);
  console.log(`Total migrated: ${totalMigrated}`);
}

// Run the migration
migrateMarketingAssets().catch(console.error);