# Dfinitiv Engineering Standards & Best Practices

## Language & Stack

This is primarily a TypeScript codebase. Always check for type errors after making changes (`npm run check`). Use strict typing — avoid `any` and unsafe casts.

## General Instructions

When the user says 'this' or references something ambiguous, look at the current branch, recent git diff, and open files before asking for clarification.

## Accessing AWS Environments

You are authorized to perform **READ ONLY** operations to assist with bug catching, planning, and triaging.

### How to Authenticate

Run `echo "<number>" | sso` to authenticate into a read-only account. The `sso` script is interactive, but piping the number works for non-interactive use.

**Environment naming convention:** 1 = development, 3 = test, 5 = stage, 9 = production

| # | Profile | Customer | Environment |
|---|---|---|---|
| 10 | pegasus-9-read-only | Pegasus | Production |
| 13 | demo-1-read-only | Demo | Development |
| 14 | demo-3-read-only | Demo | Test |
| 15 | demo-9-read-only | Demo | Production |
| 16 | pegasus-1-read-only | Pegasus | Development |
| 17 | pegasus-3-read-only | Pegasus | Test |
| 18 | pegasus-5-read-only | Pegasus | Stage |

### After Authentication

- `AWS_PROFILE` is automatically set in the shell for subsequent `aws` CLI commands.
- All profiles use `ReadOnlyAccess` role — no writes, no mutations, no deployments.
- All profiles use `us-east-1` region and the shared `dfinitiv` SSO session.

### SSO Session Expiry

If the SSO session has expired, the script will trigger a browser-based approval flow automatically. When this happens, inform the user that browser approval is needed and wait for confirmation before proceeding with AWS commands.


This guide provides comprehensive coding standards, architectural patterns, and best practices for all Dfinitiv repositories.

## Related Documentation

- **[SECURITY.md](SECURITY.md)** - Security standards and practices
- **[COMPLIANCE.md](COMPLIANCE.md)** - SOC 2 compliance requirements
- **[CUSTOMER_ENVIRONMENTS.md](CUSTOMER_ENVIRONMENTS.md)** - Customer environment provisioning and management
- **[CLAUDE_CODE_SETUP.md](CLAUDE_CODE_SETUP.md)** - Development environment setup

## Organization Overview

**GitHub Organization**: https://github.com/dfinitiv


### Common Technologies

- **AWS CDK + TypeScript** - Infrastructure as Code
- **Serverless Event-Driven Architecture** - Lambda, EventBridge, DynamoDB
- **LaunchDarkly** - Feature flags and gradual rollouts

### Git Permissions & Guidelines

- ✅ **Read operations** - Permitted without approval
- ⚠️ **Write operations** - Require explicit approval
- ⚠️ **Pull operations** - Require explicit approval
- ❌ **Push operations** - Explicitly denied
- ⚠️ **`git add -A`** - Avoid to prevent staging unrelated files
  - Prefer staging files individually by name
  - Always ask about untracked files before staging
  - Files may belong in: commit, `.gitignore`, or left untracked

### Git Conventions

- Always check `origin/main` (not local `main`) when comparing versions, checking branch state, or determining if changes exist. Never trust the local main branch to be up-to-date.
- Run `git fetch origin` before any branch comparison or version check.

## Project Management with Linear

### When to Use Linear

**Always use Linear for:**
- ✅ **Customer-facing work** - Features, bug fixes, improvements visible to customers
- ✅ **Product development** - New functionality, UX changes, API changes
- ✅ **Customer-reported issues** - Bugs or feature requests from customers

**Optional for Linear (may track informally):**
- ⚠️ **Internal refactoring** - Code improvements without external impact
- ⚠️ **Engineering documentation** - Internal guides, standards, architecture docs
- ⚠️ **Developer tooling** - Scripts, automation for internal use
- ⚠️ **Performance optimizations** - Backend improvements without user-facing changes
- ⚠️ **Test coverage improvements** - Adding or refactoring automated tests

**Recommendation:** For work with significant impact on product quality, security, maintainability, or team efficiency, create a Linear issue for proper tracking and documentation.

### Linear-GitHub Integration

Our Linear workspace is integrated with GitHub. This enables automatic linking and status updates.

#### Linking PRs to Linear Issues

**In PR Title or Description**, reference the Linear issue:

```markdown
# Using Linear issue ID
Fixes ABC-123

# Using Linear URL
Closes https://linear.app/dfinitiv/issue/ABC-123
```

**Supported Keywords:**
- `Fixes ABC-123` - Marks issue as complete when PR merges
- `Closes ABC-123` - Marks issue as complete when PR merges
- `Resolves ABC-123` - Marks issue as complete when PR merges
- `Relates to ABC-123` - Links PR without auto-completion

**In Commit Messages** (also works):

```bash
git commit -m "feat: add offer sync caching

Improves sync performance by 50% through Redis caching.

Fixes ABC-456"
```

#### Benefits of Integration

- ✅ **Automatic status updates** - PR creation/merge updates Linear issue status
- ✅ **Traceability** - See all PRs related to an issue
- ✅ **Context** - Linear issue details visible in GitHub
- ✅ **Workflow automation** - Issues move through Linear workflow based on PR state

#### Best Practices

1. **Create Linear issue first** for customer-facing work (before starting development)
2. **Reference in first commit** or PR title for automatic linking
3. **Keep Linear updated** - Add comments about blockers, progress, questions
4. **Close issues when done** - Use "Fixes" keyword to auto-close on merge

## Pull Requests

### PR Workflow

Before creating a PR, always:
1. Confirm you're on the correct feature branch (not main)
2. Ensure the branch is based on latest `origin/main`
3. Run `prettier --write` (or the project's configured formatter) on all changed files — never skip formatting
4. Run lint/format/type checks before pushing

### Automated PR Review

After creating a PR, watch for automated review feedback posted as a GitHub comment (usually arrives within 3-5 minutes). Read the feedback and address any suggestions that make sense.

### What Makes a Good PR

#### PR Name
- Something **easily understood by others**
- Think of it as the **title of a book**
- Examples:
  - ✅ "Add CDC event handler for brand deletion"
  - ✅ "Fix race condition in offer sync"
  - ❌ "Updates" (too vague)
  - ❌ "Fix stuff" (not descriptive)

#### Commits in a PR
- Each commit should have a **single purpose**
- The name and description of each commit should reflect that purpose
- Think of commits as **chapters of a book**
- Use conventional commit format where appropriate:
  - `feat:` - New feature
  - `fix:` - Bug fix
  - `refactor:` - Code refactoring
  - `docs:` - Documentation changes
  - `test:` - Test additions or changes
  - `chore:` - Maintenance tasks

#### Code in a PR
- Think of the code as the **words of each chapter**
- Code should be clean, well-commented, and follow established patterns
- Use established constructs and helpers (see "Using @dfinitiv/constructs" section)

#### PR Description

The PR description should contain **as much detail as possible** so that others can understand the intended result **without reading the code**.

**Essential Elements**:

1. **Purpose** - What problem does this solve?
2. **Approach** - How does this solve it?
3. **Links** - Supporting context:
   - Dependent PRs
   - Linear Issues
   - GitHub Issues
   - Documentation
   - Blog posts or references
4. **Before/After Changes**:
   - **For UI**: Screenshots or videos
   - **For API**: Detailed interface changes
     - Endpoint
     - HTTP Verb
     - Path
     - Querystring parameters
     - Headers
     - Request/Response format
     - Example requests/responses
5. **Testing** - How to verify the changes work
6. **Migration Notes** - Any breaking changes or deployment steps

**Example PR Description**:

```markdown
## Purpose
Fixes race condition in offer sync that caused duplicate offers to be created
when multiple sync operations ran concurrently.

Fixes ABC-789
Closes #123

## Approach
- Add distributed lock using DynamoDB conditional writes
- Use `syncedAt` timestamp as lock key
- Implement exponential backoff retry for lock acquisition

## Changes

### API Changes
None - internal implementation only

### Database Changes
- Add `syncLockExpiry` attribute to STATUS items
- Uses existing `updatedAt` for lock timestamp

## Testing
1. Deploy to dev environment
2. Trigger multiple concurrent syncs: `npm run sync-offers -- --brandId 227 &`
3. Verify only one sync proceeds, others wait
4. Check CloudWatch logs for lock acquisition messages

## Links
- Related issue: #123
- Lock pattern reference: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithItems.html#WorkingWithItems.ConditionalUpdate
```


### PR Checklist

Before submitting a PR, ensure:

- [ ] **Single purpose** - PR addresses one logical change
- [ ] **Clear title** - Descriptive and understandable
- [ ] **Detailed description** - Includes purpose, approach, links, testing
- [ ] **Clean commits** - Each commit has a single purpose with clear message
- [ ] **Tests pass** - `npm run test`, `npm run lint`, `npm run check` all pass
- [ ] **Tests added** - New functionality has corresponding tests
- [ ] **Documentation updated** - README, ARCHITECTURE, inline comments
- [ ] **Code style matches** - Follows existing patterns and uses constructs
- [ ] **No secrets** - No API keys, credentials, or sensitive data
- [ ] **Dependencies updated** - If `/package` changed, version bumped

## Using @dfinitiv/constructs (CRITICAL)

**BEFORE implementing ANY AWS service interaction, Lambda handler, event handling, or common functionality:**

1. **ALWAYS search for existing helpers** using MCP tools:
   - `mcp__dfinitiv-constructs__find_symbol` - Search for constructs/helpers
   - `mcp__dfinitiv-constructs__open_doc` - Get detailed documentation
   - `mcp__dfinitiv-constructs__list_examples` - View code examples

2. **Common searches**:
   - "dynamodb" - DynamoDB helpers (getDynamoItem, updateDynamoItem, etc.)
   - "s3" - S3 helpers (getS3Client, encodePossiblyLargePayload, etc.)
   - "logger" - Logging utilities
   - "initApiHandler" - Lambda handler patterns
   - "eventbridge" - Event handling utilities
   - "opensearch" - OpenSearch helpers

3. **Service-Specific MCP Tools**:
   - `mcp__dfinitiv-mojo-offers__*` - For mojo-offers service integration
   - `mcp__dfinitiv-savvy-metadata__*` - For savvy-metadata service integration

**Never create custom implementations for functionality that exists in constructs.**

## Lambda Handler Patterns

### Handler Types by Trigger

**API Gateway** → `initApiHandler`
```typescript
import { ApiHandler, initApiHandler } from "@dfinitiv/constructs/lambda/initApiHandler";

const apiHandler: ApiHandler<RequestBody, ResponseData> = async ({
  body,
  pathParameters,
  headers
}) => {
  // Return { statusCode, data }
  return { statusCode: 200, data: result };
};

export const handler = initApiHandler({ apiHandler });
```

**SQS Queue** → `initQueueHandler` (standard for EventBridge consumption)
```typescript
import { QueueHandler, initQueueHandler } from "@dfinitiv/constructs/lambda/initQueueHandler";

const queueHandler: QueueHandler<EventPayload> = async ({ records }) => {
  for (const record of records) {
    try {
      await processRecord(record);
    } catch (error) {
      await Logger.error({
        message: "Processing failed",
        error: error as Error,
        data: { record }
      });
    }
  }
};

export const handler = initQueueHandler({ queueHandler });
```

**EventBridge Direct** → `initEventHandler` (use sparingly - only for non-critical operations)
```typescript
import { EventHandler, initEventHandler } from "@dfinitiv/constructs/lambda/initEventHandler";

const eventHandler: EventHandler<EventData> = async ({ data }) => {
  // Process event
};

export const handler = initEventHandler({ eventHandler });
```

## DynamoDB Best Practices

### CRITICAL: Always Use Constructs Functions

**NEVER** use AWS SDK DynamoDB commands directly. **ALWAYS** use `@dfinitiv/constructs/lambda/dynamodb`.

#### Why?
- Automatic table name injection from `process.env.TABLE_NAME`
- Simplified parameters (plain objects, no AttributeValue wrapping)
- Automatic marshalling/unmarshalling
- Consistent error handling

#### Common Operations

**Get Item**:
```typescript
import { getDynamoItem } from "@dfinitiv/constructs/lambda/dynamodb";

const { Item } = await getDynamoItem({
  Key: { pk: 'USER#123', sk: 'META' }
});
```

**Put Item**:
```typescript
import { putDynamoItem } from "@dfinitiv/constructs/lambda/dynamodb";

await putDynamoItem({
  item: {
    pk: 'USER#123',
    sk: 'PROFILE',
    name: 'John',
    createdAt: new Date().toISOString()
  }
});
```

**Update Item** (with conditional create):
```typescript
import { updateDynamoItem } from "@dfinitiv/constructs/lambda/dynamodb";

await updateDynamoItem({
  Key: { pk: 'USER#123', sk: 'META' },
  attributesToSet: {
    updatedAt: new Date().toISOString(),
    "createdAt?": new Date().toISOString(),  // Only set on create (note the ?)
    "nested.attribute": value,  // Dot notation for nested attributes
  },
  attributesToDelete: ["oldAttribute"],
  nestedAttributeSeparator: ".",
});
```

**Query**:
```typescript
import { buildQueryCommandInput, dynamoQueryIterator } from "@dfinitiv/constructs/lambda/dynamodb";

const query = buildQueryCommandInput({
  indexName: 'gsi1',  // Optional - omit for main table
  keyFilter: [
    { attribute: "gsi1pk", operator: "=", value: "BRAND#123" },
    { attribute: "gsi1sk", operator: "prefix", value: "OFFER" },
  ],
  limit: 10
});

for await (const item of dynamoQueryIterator(query)) {
  // Process item - already unmarshalled
}
```

**Batch Get**:
```typescript
import { dynamoBatchGetIterator } from "@dfinitiv/constructs/lambda/dynamodb";

const Keys = ids.map(id => ({ pk: "OFFER", sk: id }));
const input = {
  RequestItems: {
    [process.env.TABLE_NAME!]: { Keys }
  }
};

for await (const item of dynamoBatchGetIterator({ input })) {
  // Process item
}
```

**Delete Item**:
```typescript
import { deleteDynamoItem } from "@dfinitiv/constructs/lambda/dynamodb";

await deleteDynamoItem({
  Key: { pk: 'USER#123', sk: 'META' }
});
```

**TTL Helpers**:
```typescript
import { getTTL } from "@dfinitiv/constructs/lambda/dynamodb";

// Returns a Unix timestamp (seconds) for the given duration from now
const ttl = getTTL({ days: 30 }); // 30 days from now
```

**Update + Return Item**:
```typescript
import { updateDynamoItemWithGet } from "@dfinitiv/constructs/lambda/dynamodb";

// Same as updateDynamoItem but returns the updated item
const updatedItem = await updateDynamoItemWithGet({
  Key: { pk: 'USER#123', sk: 'META' },
  attributesToSet: { status: 'active' },
});
```

**Scan** (use sparingly — prefer queries):
```typescript
import { buildScanCommandInput, dynamoScanIterator } from "@dfinitiv/constructs/lambda/dynamodb";

const scan = buildScanCommandInput({ /* filter options */ });
for await (const item of dynamoScanIterator(scan)) {
  // Process item
}
```

## Event-Driven Architecture (EDA)

### Publishing Events

**ALWAYS use putEvent helper**:
```typescript
import { putEvent } from "@dfinitiv/constructs/lambda/eventbridge";
import { EventDetailTypes } from "../../../package/enums/EventDetailTypes";
import { EVENT_SOURCE } from "../../../package/consts/EventSource";

await putEvent({
  source: EVENT_SOURCE,
  type: EventDetailTypes.BrandFound,
  data: JSON.stringify(eventData),
});
```

### Consuming CDC Events (DynamoDB Streams)

**Pattern**: DynamoDB → Streams → EventBridge Pipe → SQS → Lambda

#### DynamoItemChangedEvent Interface

The full interface available after decoding:

```typescript
interface DynamoItemChangedEvent<T = { [key: string]: any }> {
  after: Partial<T>;           // Item state after change (partial, only changed fields on MODIFY)
  before: Partial<T>;          // Item state before change (partial, only changed fields on MODIFY)
  newImage?: T;                // Full item after change (undefined on REMOVE)
  oldImage?: T;                // Full item before change (undefined on INSERT)
  attributesChanged: string[]; // List of changed attribute names
  operation: string;           // 'INSERT' | 'MODIFY' | 'REMOVE'
  pk: string;                  // Partition key of the changed item
  sk: string;                  // Sort key of the changed item
  userId?: string;             // User ID if available
  imagesUrl?: string;          // S3 URL for images when item ≥64KB
}
```

**`after`/`before` vs `newImage`/`oldImage`**: Both are available. Use `newImage`/`oldImage` for the full item snapshot. Use `after`/`before` when you only need the changed fields (useful for detecting deltas on MODIFY). The `pk` and `sk` fields provide direct access to the item's keys without needing to dig into the images.

#### Example Handler

```typescript
import { initQueueHandler, QueueHandler } from "@dfinitiv/constructs/lambda/initQueueHandler";
import { DynamoItemChangedEvent } from "@dfinitiv/constructs/lambda/interfaces/DynamoItemChangedEvent";
import { decodeDynamoItemChangedEvent } from "@dfinitiv/constructs/lambda/dynamodb";

const queueHandler: QueueHandler<DynamoItemChangedEvent> = async ({ records }) => {
  for (const record of records) {
    const event = await decodeDynamoItemChangedEvent(record);
    const { operation, newImage, oldImage, attributesChanged, pk, sk } = event;

    switch (operation) {
      case "INSERT":
        // newImage available, oldImage is undefined
        // ALL attributes present in attributesChanged
        await handleInsert(newImage);
        break;
      case "MODIFY":
        // Both newImage and oldImage available (for items < 64KB)
        // Only CHANGED attributes in attributesChanged
        if (attributesChanged?.includes("status")) {
          await handleStatusChange(newImage, oldImage);
        }
        break;
      case "REMOVE":
        // oldImage available, newImage is undefined
        // ALL attributes present in attributesChanged
        await handleRemove(oldImage);
        break;
    }
  }
};

export const handler = initQueueHandler({ queueHandler });
```

#### CDC Event Characteristics

- **INSERT**: Only `newImage` present (ALL attributes listed in `attributesChanged`)
- **MODIFY**: Both images for items < 64KB (ONLY changed attributes in `attributesChanged`)
- **REMOVE**: Only `oldImage` present (ALL attributes listed in `attributesChanged`)
- **Large items (≥64KB)**: Images stored in S3 via `imagesUrl`, `decodeDynamoItemChangedEvent` fetches and hydrates `newImage`/`oldImage` automatically

#### EventBridge Filtering Gotchas

❌ **Don't filter INSERT by nested attributes**:
```typescript
// Won't work reliably for INSERT - all attributes are listed
"attributesChanged": ["merchant.rebate.value"]
```

✅ **Filter by top-level attribute**:
```typescript
// Works for both INSERT and MODIFY
"attributesChanged": ["merchant"]
```

✅ **Include both INSERT and MODIFY in eventName filter**:
```typescript
{
  "eventName": ["INSERT", "MODIFY"],
  "attributesChanged": ["merchant"]
}
```

## Inter-Service Communication

### ALWAYS Use Typed API Clients

**NEVER** use raw `fetch` or `makeIAMRequest` directly for internal service calls.

#### Pattern

**1. Grant Permission** (in `lib/routes/endpoints-*.ts`):
```typescript
import { savvyMetadataInternalApi } from "@dfinitiv/savvy-metadata/endpoints/internalApi";
import { EndpointLambda } from "@dfinitiv/constructs/cdk/interfaces/EndpointLambda";
import { join } from "path";

export const endpoints = ({ table }): EndpointLambda[] => [
  {
    path: 'offers/search',
    method: 'POST',
    entry: join(__dirname, "../lambda/internal/search-offers.ts"),
    dynamoRead: {
      TABLE_NAME: table,
    },
    internalApis: {
      ...savvyMetadataInternalApi,  // Grant permission to call savvy-metadata
    },
  },
];
```

**2. Use Client** (in Lambda handler):
```typescript
import { savvyMetadataApiClient } from "@dfinitiv/savvy-metadata/endpoints/client";

const response = await savvyMetadataApiClient.getBrandById({
  pathParameters: { brandId: '123' },
  body: null,
});

// Response is typed according to the endpoint definition
if (response.statusCode === 200) {
  const brand = response.data;
  // brand is properly typed
}
```

### Available Service Clients

- `@dfinitiv/savvy-metadata/endpoints/client` - Brand/tag/category metadata
- `@dfinitiv/mojo-offers/endpoints/client` - Offer management
- `@dfinitiv/mojo-users/endpoints/client` - User management and authentication
- `@dfinitiv/savvy-geo/endpoints/client` - Geospatial search
- `@dfinitiv/savvy-cartera/endpoints/client` - Cartera merchant data
- `@dfinitiv/savvy-guides/endpoints/client` - Guide/recommendation service
- `@dfinitiv/savvy-media/endpoints/client` - Media/image management
- `@dfinitiv/savvy-analytics/endpoints/client` - Analytics and event data
- `@dfinitiv/savvy-arch/endpoints/client` - Architecture/configuration service
- `@dfinitiv/savvy-chat/endpoints/client` - Chat/conversational AI
- `@dfinitiv/savvy-rewards-network/endpoints/client` - Rewards Network dining offers

## Logging Standards

### ALWAYS Use Dfinitiv Logger

**CRITICAL**: Always `await Logger.error()` - it emits events to EventBridge

```typescript
import { Logger } from "@dfinitiv/constructs/lambda/logger";

// Info logging (no await needed)
Logger.info({
  message: "Processing offers",
  data: { count: offers.length, brandId },
});

// Error logging (MUST await!)
try {
  // ...
} catch (error) {
  await Logger.error({
    message: "Failed to process offer",
    error: error as Error,  // Include Error object for stack trace
    data: { offerId, brandId },  // Additional context
  });
  throw error;  // Re-throw if needed
}

// Warning logging (no await needed)
Logger.warn({
  message: "Offer missing required field",
  data: { offerId, field: "merchantId" },
});

// Debug logging (no await needed)
Logger.debug({
  message: "Processing step completed",
  data: { step: "validation", offerId },
});
```

### Structured Logging Best Practices

- Always include a clear `message` string
- Use `data` object for structured context (not string concatenation)
- Include relevant IDs for tracing (userId, offerId, brandId, etc.)
- Pass `Error` objects to `error` property for proper stack traces
- Use appropriate log levels (error, warn, info, debug)

## LaunchDarkly Feature Flags

Most repos use LaunchDarkly for feature toggling and gradual rollouts. The integration differs between **Lambda (server-side)** and **UI (client-side)** contexts.

### Lambda (Server-Side)

Use the constructs helper to fetch individual flag values:

```typescript
import { getLaunchDarklyFlagValue } from "@dfinitiv/constructs/lambda/launch-darkly";

const isEnabled = await getLaunchDarklyFlagValue("cartera.online.sync");

if (!isEnabled) {
  Logger.info({ message: "Online sync disabled by feature flag" });
  return;
}
```

For user-targeted flags (e.g., per-device or per-user rollouts), pass a context:

```typescript
import { getLaunchDarklyFlagValue } from "@dfinitiv/constructs/lambda/launch-darkly";
import type { LDMultiKindContext } from "@launchdarkly/node-server-sdk";

const ldContext: LDMultiKindContext = {
  kind: "multi",
  user: { key: userId },
  device: { key: deviceId },
};

const isEnabled = await getLaunchDarklyFlagValue("feature.name", tracer, {
  context: ldContext,
});
```

### UI (Client-Side)

Frontend apps use the official LaunchDarkly JS client SDK directly — **not** the constructs helper.

**Setup** (e.g., in a Svelte/React store or initialization module):
```typescript
import { initialize } from "launchdarkly-js-client-sdk";
import type { LDClient } from "launchdarkly-js-client-sdk";

// Initialize with a client-side SDK key (NOT a server-side key)
const ldClient = initialize(clientSideId, {
  kind: "user",
  key: "anonymous",
  anonymous: true,
});

await ldClient.waitForInitialization();
```

**Reading flags:**
```typescript
// Single flag
const isEnabled = ldClient.variation("feature.name", false);

// All flags
const allFlags = ldClient.allFlags();

// Listen for changes
ldClient.on("change:feature.name", (newValue, oldValue) => {
  // React to flag change
});
```

The client-side SDK key is typically stored in SSM at `/launchdarkly/client-side-key` and injected as a Vite/build env variable (e.g., `VITE_LAUNCHDARKLY_CLIENT_ID`).

### Naming Conventions

- `service.feature.enabled` - Boolean toggles (e.g., `cartera.online.sync`)
- `service.feature.percentage` - Gradual rollouts (e.g., `offers.new-algorithm.percentage`)
- `service.config.value` - Configuration values (e.g., `offers.batch.size`)

### Examples from Services

```typescript
// cartera.online.sync - Enable/disable online offer sync
const ldFlagValue = await getLaunchDarklyFlagValue("cartera.online.sync");
if (!ldFlagValue) {
  Logger.info({ message: "Online sync disabled by feature flag" });
  return;
}

// giftcards.show - Control giftcard visibility
const showGiftcards = await getLaunchDarklyFlagValue("giftcards.show");
```

## S3 Interaction

### Get S3 Client

```typescript
import { getS3Client } from "@dfinitiv/constructs/lambda/s3";

const s3 = getS3Client();
```

### Pre-signed URLs

Use for temporary, secure access to S3 objects:

```typescript
import { getS3Client } from "@dfinitiv/constructs/lambda/s3";
import { GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const s3 = getS3Client();
const presignedUrl = await getSignedUrl(
  s3,
  new GetObjectCommand({
    Bucket: process.env.BUCKET_NAME,
    Key: "reference.json"
  }),
  { expiresIn: 3600 } // 1 hour
);
```

### Large Payload Handling

Automatically handle whether payloads should be returned directly or via S3:

**Encoding (in producer Lambda)**:
```typescript
import { encodePossiblyLargePayload } from "@dfinitiv/constructs/lambda/s3";

const offersArray = Object.values(offers);
const responsePayload = await encodePossiblyLargePayload({
  bucket: process.env.OFFERS_BUCKET!,
  payload: { offers: offersArray },
});

return {
  statusCode: 200,
  data: responsePayload, // { offers: [...] } or { presignedUrl: '...' }
};
```

**Decoding (in consumer)**:
```typescript
import { decodePossiblyLargePayload } from "@dfinitiv/constructs/lambda/s3";

const response = await apiClient.getOffers({ ... });
const data = await decodePossiblyLargePayload(response.data);
// data.offers is now available regardless of whether it came from S3
```

## Testing Philosophy

### Focus on Behavior, Not Implementation

**DO Test**:
- Database operations (creates, updates, deletes)
- Event emissions (verify correct events sent to EventBridge)
- Error handling behavior (how errors are caught and handled)
- Data transformations (input → output correctness)
- Business logic (offer eligibility, calculations, etc.)
- API response structures (status codes, data shape)

**DON'T Test**:
- Info/debug log messages (implementation details that change frequently)
- Progress logging ("Processing item 5 of 10")
- Internal implementation details (private function calls, loop iterations)

### Why?

Tests should validate WHAT the code does, not HOW it does it. This makes tests:
- More resilient to refactoring
- Easier to maintain
- Focused on actual requirements

### Test Commands

```bash
npm run test                      # Run all tests
npm test -- path/to/file.test.ts  # Run specific test
npm run lint                      # Check code style
npm run check                     # TypeScript type checking
```

### Before Requesting Commit

1. ✅ Run `npm run test` - All tests must pass
2. ✅ Run `npm run lint` - Fix all linting issues
3. ✅ Run `npm run check` - Fix TypeScript errors
4. ✅ Remove brittle tests that break on refactoring
5. ✅ Update tests if component/handler API changed

## Data Validation with Zod

### ALWAYS use Zod for validation

Search for "zod" using `mcp__dfinitiv-constructs__find_symbol` for utilities.

```typescript
import { z } from "@dfinitiv/constructs/shared/zod";
import { parseZodErrorToString } from "@dfinitiv/constructs/shared/zod";

// Define schema
const RequestSchema = z.object({
  brandId: z.string(),
  limit: z.number().optional(),
});

// Validate in handler
const apiHandler: ApiHandler<RequestBody, ResponseData> = async ({ body }) => {
  const parsed = RequestSchema.safeParse(body);

  if (!parsed.success) {
    return {
      statusCode: 400,
      data: {
        message: `Invalid request body. ${parseZodErrorToString(parsed.error)}`
      }
    };
  }

  // Use parsed.data (properly typed)
  const { brandId, limit } = parsed.data;
  // ...
};
```

### Schema Definition Location

Define schemas in `package/interfaces/`:
- `package/interfaces/request/*.ts` - API request schemas
- `package/interfaces/response/*.ts` - API response schemas
- `package/interfaces/event/*.ts` - Event payload schemas

## Package Versioning

### When to Bump package.json Version

**CRITICAL**: If your repo has a `/package` directory that's consumed by other repos:

- **ANY change** to `/package` contents requires version bump in `/package/package.json`
- Changes include:
  - New/modified interfaces
  - New/modified endpoints
  - New/modified events
  - Updated constants/enums
  - Updated utilities
  - Updated API clients

### How to Bump

```bash
# In /package/package.json
# Patch: 0.1.0 → 0.1.1 (bug fixes, backward compatible)
# Minor: 0.1.0 → 0.2.0 (new features, backward compatible)
# Major: 0.1.0 → 1.0.0 (breaking changes)
```

### Important Notes

- Consuming repos must update their dependency version to get changes
- Run `npm run build` after changes to generate updated `/package/dist`
- Test consuming repos locally using `npm link` before publishing

## OpenSearch Interaction

### Get OpenSearch Client

```typescript
import { getOpensearchClient, errors } from "@dfinitiv/constructs/lambda/opensearch";

const osClient = getOpensearchClient();
```

### Common Operations

```typescript
// Search
try {
  const osResponse = await osClient.search({
    index: 'offers',
    body: {
      query: {
        match: { brandId: '123' }
      }
    }
  });

  const hits = osResponse.body.hits.hits;
  // Process results
} catch (error) {
  if (error instanceof errors.ResponseError) {
    await Logger.error({
      message: "OpenSearch Response Error",
      error: error as Error,
      data: { query }
    });
  }
  throw error;
}
```

### Indexing with Retries

For high-throughput scenarios, handle rate limiting:

```typescript
// See service-specific opensearch-utils.ts for indexWithRetry helper
import { indexWithRetry } from "../common/opensearch-utils";

await indexWithRetry({
  osClient,
  index: 'offers',
  id: offerId,
  body: offerDocument,
});
```

## Standard Project Structure

All CDK/TypeScript repos follow this structure:

```
repo-name/
├── bin/                          # CDK deployment entry point
│   └── repo-name.ts
├── lib/
│   ├── repo-name-stack.ts        # Main CDK stack (extends SavvyStack)
│   ├── routes/
│   │   ├── endpoints-internal.ts # Internal API definitions
│   │   ├── endpoints-ios.ts      # iOS API definitions
│   │   ├── endpoints-web.ts      # Web API definitions
│   │   └── events.ts             # EventBridge handler definitions
│   └── lambda/
│       ├── common/               # Shared utilities
│       │   ├── ddb-helpers/      # DynamoDB entity helpers
│       │   └── utils.ts
│       ├── internal/             # Internal API handlers
│       ├── ios/                  # iOS API handlers
│       ├── web/                  # Web API handlers
│       └── event/                # EventBridge handlers
├── package/                      # Exported package (if applicable)
│   ├── package.json              # MUST bump version on ANY changes
│   ├── README.md
│   ├── consts/
│   │   ├── EventSource.ts        # Service event source constant
│   │   └── Provider.ts           # Service provider (if applicable)
│   ├── endpoints/
│   │   ├── client.ts             # Generated API client
│   │   └── internalApi.ts        # API ID export for permissions
│   ├── enums/
│   │   └── EventDetailTypes.ts   # Event type enumerations
│   ├── events/
│   │   └── client.ts             # Event client
│   └── interfaces/
│       ├── data/                 # General data interfaces
│       ├── event/                # Event payload interfaces
│       ├── request/              # API request interfaces
│       └── response/             # API response interfaces
├── test/                         # Tests (mirrors lib/ structure)
│   ├── lambda/
│   │   ├── event/
│   │   ├── internal/
│   │   └── common/
│   └── utils/
├── scripts/                      # Utility scripts
│   ├── common/                   # Shared script utilities
│   └── *.ts                      # Individual scripts
├── doc/ (or docs/)               # Documentation
│   ├── architecture/             # Architectural docs and diagrams
│   └── *.md
├── .github/
│   └── workflows/                # GitHub Actions
├── README.md                     # Project introduction
├── ARCHITECTURE.md               # Architectural overview
├── CLAUDE.md                     # Project-specific Claude guidance
├── package.json
├── tsconfig.json
└── cdk.json
```

## Common Development Workflows

### Adding a New Event Type

1. Define interface in `/package/interfaces/event/MyEvent.ts`
2. Add enum to `/package/enums/EventDetailTypes.ts`
3. Create emit handler in `/lib/lambda/event/emit-my-event.ts`
4. Add EventBridge pattern in `/lib/routes/events.ts`
5. Update tests in `/test/lambda/event/emit-my-event.test.ts`
6. Bump `/package/package.json` version

### Adding a New API Endpoint

1. Create handler in `/lib/lambda/internal/my-endpoint.ts`
2. Define in `/lib/routes/endpoints-internal.ts`
3. Add request/response interfaces in `/package/interfaces/`
4. Update API client (typically auto-generated)
5. Add tests in `/test/lambda/internal/my-endpoint.test.ts`
6. Bump `/package/package.json` version

### Debugging CDC Events

1. Check CloudWatch logs for stream handler
2. Verify `attributesChanged` array in event payload
3. Check `newImage`/`oldImage` availability (depends on operation)
4. Validate EventBridge pattern matches actual event structure
5. Remember: INSERT has ALL attributes in `attributesChanged`# UI Screenshot Automation Instructions

## Auto-Detection Rules

When working in a directory that matches ANY of these patterns, Claude should automatically offer to take screenshots:

### Frontend Framework Detection
- Contains `package.json` with any of: react, vue, angular, svelte, next, nuxt, gatsby, astro, solid
- Contains files: `vite.config.*`, `webpack.config.*`, `next.config.*`, `nuxt.config.*`
- Has directories: `src/components`, `src/pages`, `src/views`, `app/`, `pages/`
- Has file extensions: `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`

### UI-Related Keywords in Path
- Path contains: `/frontend`, `/client`, `/web`, `/ui`, `/app`, `/dashboard`, `/admin`

## Automatic Behavior

When Claude detects a UI project:

### 1. Development Server Detection
```bash
# Check for running dev servers on common ports
lsof -i :3000 -i :3001 -i :4200 -i :5173 -i :8080 -i :8000 2>/dev/null | grep LISTEN

# Or check for dev script in package.json
grep -E '"(dev|start|serve)"' package.json
```

### 2. Starting Dev Server (if needed)
- Look for scripts in package.json: `dev`, `start`, `serve`, `preview`
- Common commands: `npm run dev`, `npm start`, `yarn dev`, `pnpm dev`
- Wait 3-5 seconds for server to start

### 3. Chrome DevTools MCP Usage
When dev server is running:
```
1. Use mcp__chrome-devtools__new_page to open http://localhost:[PORT]
2. Wait for page load with mcp__chrome-devtools__wait_for
3. Take snapshot with mcp__chrome-devtools__take_snapshot
4. For visual changes, use mcp__chrome-devtools__take_screenshot
```

### 4. Smart Route Detection
- Check for routes in: `routes.ts`, `router.ts`, `App.tsx`, `main.tsx`
- Look for Route components, path definitions
- Common patterns to check:
  - `/` (home)
  - `/dashboard`
  - `/login`
  - Any route mentioned in recent file changes

### 5. Screenshot Strategy
```
For each significant UI change:
1. Navigate to relevant route
2. Take screenshot with: mcp__chrome-devtools__take_screenshot
3. Save to: /tmp/screenshots/[timestamp]-[feature].png
4. Keep track of screenshots for PR
```

## Pull Request Integration

When creating a PR after UI work:

### Include Screenshots in PR Body
```markdown
## Screenshots

### Before
![Before](path-to-before-screenshot)

### After
![After](path-to-after-screenshot)

### Mobile View (if applicable)
![Mobile](path-to-mobile-screenshot)
```

### Screenshot Checklist for PRs
- [ ] Homepage/main view
- [ ] Feature being changed
- [ ] Mobile responsive view (if applicable)
- [ ] Dark mode (if applicable)
- [ ] Error states (if applicable)

## Proactive Behaviors

### On File Save (UI files)
- If .tsx/.jsx/.vue file was edited → offer to screenshot
- If CSS/styling changed → definitely screenshot

### On Component Creation
- New component file → screenshot after implementation
- Suggest common test routes

### On PR Creation
- Automatically ask: "Should I take screenshots of the UI changes?"
- If yes, cycle through main routes and capture

## Example Workflow

```bash
# 1. Detect UI project
ls src/components  # Found components directory

# 2. Check/start dev server
npm run dev  # Starting on port 3000

# 3. Open browser
mcp__chrome-devtools__new_page url:"http://localhost:3000"

# 4. Take initial screenshot
mcp__chrome-devtools__take_screenshot filePath:"/tmp/screenshots/before.png"

# 5. Make changes...

# 6. Take after screenshot
mcp__chrome-devtools__take_screenshot filePath:"/tmp/screenshots/after.png"

# 7. Create PR with screenshots
gh pr create --body "$(cat <<EOF
## Changes
- Updated button styles
- Fixed responsive layout

## Screenshots
Before: /tmp/screenshots/before.png
After: /tmp/screenshots/after.png
EOF
)"
```

## Linear API Capabilities
You Should be enabled to use the linear MCP tool to view tickets but for viewing images there is also an API key available in the shell environment at LINEAR_API_KEY, you can use that with mcp or API calls to view images attached to tickets when getting descriptions.\


## Chrome DevTools MCP Capabilities

Available tools for UI automation:
- `new_page` - Open URL
- `navigate_page` - Navigate to different routes
- `take_screenshot` - Capture visual state
- `take_snapshot` - Get DOM structure
- `resize_page` - Test responsive designs
- `click`, `fill`, `hover` - Interact with UI
- `wait_for` - Wait for elements/text
- `list_console_messages` - Check for errors

## Tips

1. **Always wait after navigation**: Use `wait_for` with expected text/element
2. **Screenshot both states**: Before and after changes
3. **Test responsive**: Use `resize_page` for mobile views
4. **Check console**: Use `list_console_messages` for errors
5. **Clean up**: Close tabs with `close_page` when done
