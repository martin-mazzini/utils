Walk through the typical data flow within the system.

Usage: /explainDataFlow $ARGUMENTS

Instructions for AI Assistant:
1. Identify main entry points:
   - API endpoints (REST, GraphQL, gRPC)
   - CLI commands
   - Message queue consumers
   - Scheduled jobs/cron
   - Webhooks or event handlers
2. Trace data movement through layers:
   - Request parsing and validation
   - Authentication and authorization checks
   - Business logic processing
   - Data transformations and enrichment
   - Database operations (reads/writes)
   - External service calls
   - Response formatting
3. Map asynchronous flows:
   - Background jobs and workers
   - Event publishing and consumption
   - Queue processing patterns
   - Batch operations
   - Long-running processes
4. Document key domain events and state transitions:
   - What triggers each transition
   - Side effects of state changes
   - Event cascades and workflows
   - Compensation/rollback mechanisms
5. Analyze:
   - Data validation points
   - Transaction boundaries
   - Caching strategies
   - Error handling and recovery
   - Performance bottlenecks
6. If $ARGUMENTS specifies particular flows, detail those thoroughly
7. Create flow diagrams (in text/ASCII) for major use cases
8. Note any data flow anti-patterns or improvements

The output should reveal how data enters, transforms, and exits the system across different scenarios.

9. Memory Management:
   - If $ARGUMENTS contains "no memory", just display the analysis
   - Otherwise (default), save the analysis to memories/analysis/08-dataflow.md
   - Create the memories/analysis directory if it doesn't exist
   - Include timestamp and codebase name in the memory file