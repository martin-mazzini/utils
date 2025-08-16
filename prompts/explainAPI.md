Analyze and document the API surface and behavior if the project exposes an API.

Usage: /explainAPI $ARGUMENTS

Instructions for AI Assistant:
1. Identify if the project exposes APIs (REST, GraphQL, gRPC, WebSocket)
2. For each API found:
   - List key endpoints or routes with their purpose
   - Identify HTTP methods, paths, and parameters
   - Determine if they're public, internal, or service-to-service
   - Document what each endpoint interacts with (DB, queues, external APIs)
3. Look for:
   - OpenAPI/Swagger specifications
   - API documentation or auto-generated docs
   - Authentication and authorization patterns
   - Rate limiting and throttling
   - Request/response schemas
   - Error response formats
4. Analyze:
   - Common request flows and usage patterns
   - API versioning strategy
   - Input validation approaches
   - Response caching policies
   - CORS and security headers
5. Document:
   - API consumers (users, apps, internal systems)
   - Integration patterns
   - Webhooks or event notifications
   - Batch operations or async patterns
6. If $ARGUMENTS specifies particular endpoints or aspects, focus there
7. Build understanding of the system's interface and side effects
8. Note any API design inconsistencies or improvements

The output should provide a clear map of how external systems interact with this service.

9. Memory Management:
   - If $ARGUMENTS contains "no memory", just display the analysis
   - Otherwise (default), save the analysis to memories/analysis/06-api.md
   - Create the memories/analysis directory if it doesn't exist
   - Include timestamp and codebase name in the memory file