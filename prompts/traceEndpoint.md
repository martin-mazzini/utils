# /traceEndpoint

Trace an endpoint through all layers, providing a concise summary and clickable links to main execution points.

## Usage
```
/traceEndpoint <endpoint_path>
```

## Steps

1. **Find the endpoint definition**
   - Search for the endpoint path in router files
   - Identify the HTTP method and handler function

2. **Provide a brief summary**
   - What does this endpoint do in 1-2 sentences?

3. **Trace execution flow**
   - Follow the request through each layer with clickable links:
     - Router/Controller: `file_path:line_number`
     - Service layer: `file_path:line_number`
     - Repository/Database layer: `file_path:line_number`

4. **Document side effects**
   - Database operations (INSERT, UPDATE, DELETE)
   - Message queue publications
   - External API calls
   - File system operations
   - Cache updates

5. **Format output**
   ```
   ## Endpoint: [METHOD] /path/to/endpoint
   
   **Summary**: Brief description of what the endpoint does
   
   ### Execution Flow:
   1. **Router** → path/to/router.ts:123
      - Validates request, calls service
   
   2. **Service** → path/to/service.ts:456
      - Main business logic, orchestrates operations
   
   3. **Repository** → path/to/repository.ts:789
      - Database queries/updates
   
   ### Side Effects:
   - ✅ Inserts record into `users` table
   - 📤 Publishes message to `user.created` queue
   - 🔄 Updates cache with user data
   ```

## Implementation

When executed, I will:
1. Use Grep to find the endpoint path in router files
2. Read the handler implementation to understand the flow
3. Follow function calls through service and repository layers
4. Identify all side effects (DB operations, message publishing, etc.)
5. Present a concise trace with 3-4 main clickable links to key execution points