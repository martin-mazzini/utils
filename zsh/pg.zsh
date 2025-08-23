# PostgreSQL Database Operations for Development
# Provides convenient functions for common database operations with auto-detection of service

# Source utils for get_base_repo_name function
source ~/.config/zsh/utils.zsh

# Global associative array to cache database configurations
declare -gA PG_DB_CONFIG

# Service aliases for convenience
declare -gA PG_SERVICE_ALIASES=(
  [app]="my-app-service"
)

# _pg_load_config() - Load database configurations from db.txt
# Internal function to parse and cache database connection strings
_pg_load_config() {
  local config_file="$HOME/.config/zsh/db.txt"
  
  # Clear existing config
  PG_DB_CONFIG=()
  
  if [[ ! -f "$config_file" ]]; then
    echo "❌ Database configuration file not found: $config_file"
    return 1
  fi
  
  # Read config file line by line
  while IFS='|' read -r service connection || [[ -n "$service" ]]; do
    # Skip comments and empty lines
    [[ "$service" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$service" ]] && continue
    
    # Trim whitespace
    service="${service// /}"
    connection="${connection// /}"
    
    # Store in associative array
    PG_DB_CONFIG[$service]="$connection"
  done < "$config_file"
  
  return 0
}

# _pg_get_connection() - Get connection string for current repository or override
# Returns the PostgreSQL connection string based on service override or current repo
_pg_get_connection() {
  # Load config if not already loaded
  if [[ ${#PG_DB_CONFIG[@]} -eq 0 ]]; then
    _pg_load_config || return 1
  fi
  
  local service_name=""
  
  # Check if service override is set
  if [[ -n "$PG_SERVICE_OVERRIDE" ]]; then
    service_name="$PG_SERVICE_OVERRIDE"
  else
    # Get current repository name
    local repo_name=$(get_base_repo_name)
    
    if [[ -z "$repo_name" ]]; then
      echo "❌ Not in a git repository. Please specify a service:" >&2
      echo "   Available services: ${(k)PG_DB_CONFIG}" >&2
      echo "   Aliases: app (my-app-service)" >&2
      return 1
    fi
    
    service_name="$repo_name"
  fi
  
  # Look up connection string
  local connection="${PG_DB_CONFIG[$service_name]}"
  
  if [[ -z "$connection" ]]; then
    echo "❌ Service '$service_name' not found in db.txt." >&2
    echo "   Available services: ${(k)PG_DB_CONFIG}" >&2
    echo "   Aliases: app (my-app-service)" >&2
    return 1
  fi
  
  # Return only the connection string
  echo "$connection"
  return 0
}

# _pg_show_repo() - Display detected repository or service
# Shows the current service being used
_pg_show_repo() {
  if [[ -n "$PG_SERVICE_OVERRIDE" ]]; then
    # Show the friendly alias if applicable
    local display_name="$PG_SERVICE_OVERRIDE"
    for alias in ${(k)PG_SERVICE_ALIASES}; do
      if [[ "${PG_SERVICE_ALIASES[$alias]}" == "$PG_SERVICE_OVERRIDE" ]]; then
        display_name="$alias ($PG_SERVICE_OVERRIDE)"
        break
      fi
    done
    echo "🔍 Service: $display_name"
  else
    local repo_name=$(get_base_repo_name)
    if [[ -n "$repo_name" ]]; then
      echo "🔍 Repository detected: $repo_name"
    fi
  fi
}

# _pg_parse_service() - Parse service from arguments
# Returns service name if found, empty otherwise
# Sets global PG_SERVICE_OVERRIDE if service is specified
_pg_parse_service() {
  local first_arg="$1"
  
  # Reset override
  PG_SERVICE_OVERRIDE=""
  
  # Check if first argument is a service alias
  if [[ -n "${PG_SERVICE_ALIASES[$first_arg]}" ]]; then
    PG_SERVICE_OVERRIDE="${PG_SERVICE_ALIASES[$first_arg]}"
    return 0
  fi
  
  # Check if first argument is a full service name
  if [[ -n "${PG_DB_CONFIG[$first_arg]}" ]]; then
    PG_SERVICE_OVERRIDE="$first_arg"
    return 0
  fi
  
  # No service found
  return 1
}

# _pg_execute() - Execute SQL command with proper error handling
# Usage: _pg_execute "SQL" ["format_option"]
_pg_execute() {
  local sql="$1"
  local format_option="${2:-}"
  
  # Get connection string
  local connection=$(_pg_get_connection)
  [[ $? -ne 0 ]] && return 1
  
  # Create temp files for output
  local tmpout=$(mktemp)
  local tmperr=$(mktemp)
  
  # Execute SQL
  local exit_code
  
  if [[ -n "$format_option" ]]; then
    psql "$connection" -c "$sql" "$format_option" >"$tmpout" 2>"$tmperr"
    exit_code=$?
  else
    psql "$connection" -c "$sql" >"$tmpout" 2>"$tmperr"
    exit_code=$?
  fi
  
  # Read outputs
  local output=$(cat "$tmpout")
  local errors=$(cat "$tmperr")
  
  # Clean up temp files
  rm -f "$tmpout" "$tmperr"
  
  if [[ $exit_code -ne 0 ]]; then
    echo "❌ SQL Error:" >&2
    
    # Show psql errors
    if [[ -n "$errors" ]]; then
      echo "$errors" | grep -E "(ERROR|DETAIL|HINT|psql):" | sed 's/^/   /' >&2
    fi
    
    # Check for common issues
    if [[ "$errors" =~ "could not connect" ]]; then
      echo "   💡 Is the database service running?" >&2
    elif [[ "$errors" =~ "password authentication failed" ]]; then
      echo "   💡 Check database credentials in db.txt" >&2
    elif [[ "$errors" =~ "does not exist" ]]; then
      echo "   💡 Check if the database or table exists" >&2
    fi
    
    return $exit_code
  fi
  
  # Output the result
  echo "$output"
  return 0
}

# _pg_get_tables() - Get list of user tables in the database
# Returns array of table names excluding system tables
_pg_get_tables() {
  local sql="SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"
  local tables=$(_pg_execute "$sql" "-tA")
  [[ $? -ne 0 ]] && return 1
  
  echo "$tables"
  return 0
}

# pg-truncate() - Truncate a specific database table
# Usage: pg-truncate [service] <table_name>
pg-truncate() {
  if [[ $# -eq 0 ]]; then
    echo "❌ Usage: pg-truncate [service] <table_name>"
    echo "   Examples:"
    echo "     pg-truncate users           # Auto-detect from current repo"
    echo "     pg-truncate app chat_flow   # Use my-app-service"
    return 1
  fi
  
  # Check if first argument is a service
  _pg_load_config  # Ensure config is loaded for service parsing
  if _pg_parse_service "$1"; then
    shift  # Remove service from arguments
  fi
  
  if [[ $# -eq 0 ]]; then
    echo "❌ Table name required"
    return 1
  fi
  
  local table="$1"
  
  _pg_show_repo
  echo "🗄️  Truncating table: $table"
  
  # First, get current row count
  local count_sql="SELECT COUNT(*) FROM \"$table\";"
  local count=$(_pg_execute "$count_sql" "-tA")
  
  if [[ $? -ne 0 ]]; then
    # Table might not exist, let's check
    local tables=$(_pg_get_tables)
    if [[ $? -eq 0 ]]; then
      echo "   💡 Available tables:"
      echo "$tables" | sed 's/^/      - /'
    fi
    return 1
  fi
  
  echo "   Current rows: $count"
  
  # Truncate the table with CASCADE to handle foreign keys
  local truncate_sql="TRUNCATE TABLE \"$table\" CASCADE;"
  local result=$(_pg_execute "$truncate_sql")
  
  if [[ $? -eq 0 ]]; then
    echo "✅ Table '$table' truncated successfully"
  else
    echo "   💡 Try pg-truncate-all if there are foreign key constraints"
  fi
}

# pg-truncate-all() - Truncate all tables in the database
# Usage: pg-truncate-all [service]
pg-truncate-all() {
  # Check if first argument is a service
  if [[ $# -gt 0 ]]; then
    _pg_load_config  # Ensure config is loaded for service parsing
    if _pg_parse_service "$1"; then
      shift  # Remove service from arguments
    fi
  fi
  
  _pg_show_repo
  echo "🗄️  Truncating all tables..."
  
  # Get all tables
  local tables=$(_pg_get_tables)
  [[ $? -ne 0 ]] && return 1
  
  # Count total rows before truncation
  local total_rows=0
  local table_count=0
  
  echo "   Analyzing tables..."
  while IFS= read -r table; do
    [[ -z "$table" ]] && continue
    
    local count=$(_pg_execute "SELECT COUNT(*) FROM \"$table\";" "-tA" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
      total_rows=$((total_rows + count))
      table_count=$((table_count + 1))
      echo "      $table: $count rows"
    fi
  done <<< "$tables"
  
  echo "   Total: $table_count tables, $total_rows rows"
  echo ""
  
  # Truncate all tables at once using CASCADE
  local truncate_sql="TRUNCATE TABLE "
  local first=true
  
  while IFS= read -r table; do
    [[ -z "$table" ]] && continue
    
    if [[ "$first" == "true" ]]; then
      truncate_sql+="\"$table\""
      first=false
    else
      truncate_sql+=", \"$table\""
    fi
  done <<< "$tables"
  
  truncate_sql+=" CASCADE;"
  
  echo "   Truncating all tables..."
  local result=$(_pg_execute "$truncate_sql")
  
  if [[ $? -eq 0 ]]; then
    echo "✅ All tables truncated successfully"
  else
    echo "❌ Failed to truncate tables"
  fi
}

# pg-count() - Count rows in a database table
# Usage: pg-count [service] <table_name>
pg-count() {
  if [[ $# -eq 0 ]]; then
    echo "❌ Usage: pg-count [service] <table_name>"
    echo "   Examples:"
    echo "     pg-count users           # Auto-detect from current repo"
    echo "     pg-count app chat_flow   # Use my-app-service"
    return 1
  fi
  
  # Check if first argument is a service
  _pg_load_config  # Ensure config is loaded for service parsing
  if _pg_parse_service "$1"; then
    shift  # Remove service from arguments
  fi
  
  if [[ $# -eq 0 ]]; then
    echo "❌ Table name required"
    return 1
  fi
  
  local table="$1"
  
  _pg_show_repo
  echo "🗄️  Counting rows in table: $table"
  
  local sql="SELECT COUNT(*) FROM \"$table\";"
  local count=$(_pg_execute "$sql" "-tA")
  
  if [[ $? -eq 0 ]]; then
    echo "   📊 $table: $count rows"
  else
    # Table might not exist, let's check
    local tables=$(_pg_get_tables)
    if [[ $? -eq 0 ]]; then
      echo "   💡 Available tables:"
      echo "$tables" | sed 's/^/      - /'
    fi
  fi
}

# pg-select() - Select data from a table with optional filters
# Usage: pg-select [service] <table> [options]
pg-select() {
  if [[ $# -eq 0 ]]; then
    echo "❌ Usage: pg-select [service] <table> [options]"
    echo "   Examples:"
    echo "     pg-select chat_flow                    # Auto-detect service"
    echo "     pg-select app chat_flow                # Use my-app-service"
    echo "     pg-select app users -w \"active=true\"   # With WHERE clause"
    echo "   Options:"
    echo "     -w \"condition\"  : Add WHERE clause"
    echo "     -t              : Use table format instead of expanded display"
    echo "     -l <number>     : Limit results (default: 100)"
    echo "     -c \"col1,col2\"  : Select specific columns only"
    return 1
  fi
  
  # Check if first argument is a service
  _pg_load_config  # Ensure config is loaded for service parsing
  if _pg_parse_service "$1"; then
    shift  # Remove service from arguments
  fi
  
  if [[ $# -eq 0 ]]; then
    echo "❌ Table name required"
    return 1
  fi
  
  local table="$1"
  shift
  
  _pg_show_repo
  echo "🗄️  Selecting from table: $table"
  
  local columns="*"
  local limit=100
  local use_table_format=false
  local where_clause=""
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -w)
        if [[ -z "$2" ]]; then
          echo "❌ WHERE clause cannot be empty"
          return 1
        fi
        where_clause="$2"
        shift 2
        ;;
      -t)
        use_table_format=true
        shift
        ;;
      -l)
        if [[ -z "$2" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
          echo "❌ Limit must be a positive number"
          return 1
        fi
        limit="$2"
        shift 2
        ;;
      -c)
        if [[ -z "$2" ]]; then
          echo "❌ Column list cannot be empty"
          return 1
        fi
        columns="$2"
        shift 2
        ;;
      *)
        # Assume it's an ID if no other flags
        where_clause="id = '$1'"
        limit=1
        shift
        ;;
    esac
  done
  
  local sql="SELECT $columns FROM \"$table\""
  
  # Add WHERE clause if provided
  if [[ -n "$where_clause" ]]; then
    sql+=" WHERE $where_clause"
  fi
  
  # Add LIMIT
  sql+=" LIMIT $limit"
  sql+=";"
  
  # Execute query
  local result
  if [[ "$use_table_format" == true ]]; then
    result=$(_pg_execute "$sql")
  else
    # Default to expanded display for better readability
    result=$(_pg_execute "$sql" "-x")
  fi
  
  if [[ $? -eq 0 ]]; then
    echo "$result"
    
    # Show hint if we hit the limit
    if [[ $limit -eq 100 ]]; then
      local row_count=$(echo "$result" | grep -c "^-\[ RECORD")
      if [[ "$use_table_format" == true ]]; then
        # For table format, count actual data rows (excluding header and footer)
        row_count=$(echo "$result" | grep -v "^(" | grep -v "^-" | grep -v "^$" | wc -l)
        row_count=$((row_count - 1)) # Subtract header row
      fi
      
      if [[ $row_count -eq $limit ]]; then
        echo ""
        echo "   💡 Showing first $limit rows. Use -l <number> to change limit or WHERE clause to filter."
      fi
    fi
  fi
}

# pg-select-all() - Show row counts for all tables
# Usage: pg-select-all [service]
pg-select-all() {
  # Check if first argument is a service
  if [[ $# -gt 0 ]]; then
    _pg_load_config  # Ensure config is loaded for service parsing
    if _pg_parse_service "$1"; then
      shift  # Remove service from arguments
    fi
  fi
  
  _pg_show_repo
  echo "🗄️  Database Summary"
  echo ""
  
  # Get all tables
  local tables=$(_pg_get_tables)
  [[ $? -ne 0 ]] && return 1
  
  # Header
  printf "%-30s %10s\n" "TABLE" "ROWS"
  printf "%-30s %10s\n" "==============================" "=========="
  
  local total_rows=0
  local table_count=0
  
  while IFS= read -r table; do
    [[ -z "$table" ]] && continue
    
    local count=$(_pg_execute "SELECT COUNT(*) FROM \"$table\";" "-tA" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
      printf "%-30s %10s\n" "$table" "$count"
      total_rows=$((total_rows + count))
      table_count=$((table_count + 1))
    fi
  done <<< "$tables"
  
  # Footer
  printf "%-30s %10s\n" "==============================" "=========="
  printf "%-30s %10s\n" "TOTAL ($table_count tables)" "$total_rows"
}

# pg-insert() - Insert a dummy record into a table
# Usage: pg-insert [service] <table_name>
pg-insert() {
  if [[ $# -eq 0 ]]; then
    echo "❌ Usage: pg-insert [service] <table_name>"
    echo "   Examples:"
    echo "     pg-insert users           # Auto-detect from current repo"
    echo "     pg-insert app chat_flow   # Use my-app-service"
    return 1
  fi
  
  # Check if first argument is a service
  _pg_load_config  # Ensure config is loaded for service parsing
  if _pg_parse_service "$1"; then
    shift  # Remove service from arguments
  fi
  
  if [[ $# -eq 0 ]]; then
    echo "❌ Table name required"
    return 1
  fi
  
  local table="$1"
  
  _pg_show_repo
  echo "🗄️  Inserting dummy record into table: $table"
  
  # Get column information
  local column_sql="
    SELECT 
      column_name,
      data_type,
      is_nullable,
      column_default
    FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = '$table'
      AND column_name != 'id'
      AND column_default IS NULL OR column_default NOT LIKE 'nextval%'
    ORDER BY ordinal_position;"
  
  local columns=$(_pg_execute "$column_sql" "-tA")
  [[ $? -ne 0 ]] && return 1
  
  # Build INSERT statement
  local insert_sql="INSERT INTO \"$table\" ("
  local values_sql=" VALUES ("
  local first=true
  
  while IFS='|' read -r col_name data_type is_nullable col_default; do
    [[ -z "$col_name" ]] && continue
    
    # Skip auto-generated columns
    [[ "$col_default" =~ nextval ]] && continue
    
    if [[ "$first" == "true" ]]; then
      first=false
    else
      insert_sql+=", "
      values_sql+=", "
    fi
    
    insert_sql+="\"$col_name\""
    
    # Generate dummy value based on data type
    case "$data_type" in
      *int*)
        values_sql+="1"
        ;;
      *numeric*|*decimal*|*float*|*double*)
        values_sql+="1.0"
        ;;
      *boolean*)
        values_sql+="true"
        ;;
      *timestamp*|*date*)
        values_sql+="CURRENT_TIMESTAMP"
        ;;
      *json*)
        values_sql+="'{}'"
        ;;
      *uuid*)
        values_sql+="gen_random_uuid()"
        ;;
      *)
        # Default to string
        values_sql+="'test'"
        ;;
    esac
  done <<< "$columns"
  
  insert_sql+=")$values_sql) RETURNING *;"
  
  # Execute insert
  echo "   Executing: $(echo "$insert_sql" | head -c 80)..."
  local result=$(_pg_execute "$insert_sql" "-x")
  
  if [[ $? -eq 0 ]]; then
    echo "✅ Record inserted successfully:"
    echo "$result"
  fi
}

# pg-list() - List tables or columns in a table
# Usage: pg-list [service] [table_name]
pg-list() {
  # Check if first argument is a service
  local table=""
  if [[ $# -gt 0 ]]; then
    _pg_load_config  # Ensure config is loaded for service parsing
    if _pg_parse_service "$1"; then
      shift  # Remove service from arguments
    fi
    # Next argument is the table name if present
    table="$1"
  fi
  
  _pg_show_repo
  
  if [[ -z "$table" ]]; then
    # List all tables
    echo "🗄️  Tables in database:"
    echo ""
    
    local sql="SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"
    local tables=$(_pg_execute "$sql" "-tA")
    
    if [[ $? -eq 0 ]]; then
      if [[ -z "$tables" ]]; then
        echo "   No tables found in database"
      else
        while IFS= read -r t; do
          [[ -n "$t" ]] && echo "   • $t"
        done <<< "$tables"
      fi
    fi
  else
    # List columns for specific table
    echo "🗄️  Columns in table: $table"
    echo ""
    
    local sql="
      SELECT 
        column_name,
        data_type,
        CASE 
          WHEN is_nullable = 'YES' THEN 'NULL'
          ELSE 'NOT NULL'
        END as nullable,
        column_default
      FROM information_schema.columns
      WHERE table_schema = 'public' 
        AND table_name = '$table'
      ORDER BY ordinal_position;"
    
    local result=$(_pg_execute "$sql")
    
    if [[ $? -eq 0 ]]; then
      echo "$result"
    else
      # Table might not exist, show available tables
      local tables=$(_pg_get_tables)
      if [[ $? -eq 0 ]]; then
        echo "   💡 Available tables:"
        echo "$tables" | sed 's/^/      - /'
      fi
    fi
  fi
}

# pg-services() - List available database services
# Shows all configured services with their aliases
pg-services() {
  echo "🗄️  Available Database Services"
  echo ""
  
  # Load config if needed
  if [[ ${#PG_DB_CONFIG[@]} -eq 0 ]]; then
    _pg_load_config || return 1
  fi
  
  # Header
  printf "%-10s %-30s %s\n" "ALIAS" "SERVICE NAME" "DATABASE"
  printf "%-10s %-30s %s\n" "==========" "==============================" "==============================" 
  
  # Show all services
  for service in ${(ok)PG_DB_CONFIG[@]}; do
    local alias=""
    # Find alias for this service
    for a in ${(k)PG_SERVICE_ALIASES}; do
      if [[ "${PG_SERVICE_ALIASES[$a]}" == "$service" ]]; then
        alias="$a"
        break
      fi
    done
    
    # Extract database name from connection string
    local conn="${PG_DB_CONFIG[$service]}"
    local db_name="${conn##*/}"  # Get everything after last /
    
    printf "%-10s %-30s %s\n" "$alias" "$service" "$db_name"
  done
  
  echo ""
  echo "💡 Usage: pg-select [alias|service] <table>"
  echo "   Example: pg-select app chat_flow"
}

# Function descriptions for zfun
declare -gA pg_function_descriptions=(
  [pg-truncate]="Truncate a specific database table"
  [pg-truncate-all]="Truncate all tables in the database"
  [pg-count]="Count rows in a database table"
  [pg-select]="Select data from a table with optional filters"
  [pg-select-all]="Show row counts for all tables"
  [pg-insert]="Insert a dummy record into a table"
  [pg-list]="List tables or columns in a table"
  [pg-services]="List available database services"
)




# pg-nuke() - DROP ALL OBJECTS in the database (tables, views, sequences, etc.)
# WARNING: This completely destroys all database objects!
# Usage: pg-nuke [service]
pg-nuke() {
  # Check if first argument is a service
  if [[ $# -gt 0 ]]; then
    _pg_load_config  # Ensure config is loaded for service parsing
    if _pg_parse_service "$1"; then
      shift  # Remove service from arguments
    fi
  fi
  
  _pg_show_repo
  echo "☢️  WARNING: This will DROP ALL objects in the database!"
  echo "   This action is IRREVERSIBLE and will:"
  echo "   • Drop all tables (including data and structure)"
  echo "   • Drop all views, sequences, types, functions"
  echo "   • Leave you with a completely empty database"
  echo ""
  
  # Get connection for database name
  local connection=$(_pg_get_connection)
  [[ $? -ne 0 ]] && return 1
  
  local db_name="${connection##*/}"
  echo "   Database: $db_name"
  echo ""
  
  # Require confirmation
  echo -n "   Confirm? (y/N): "
  read confirmation
  
  if [[ "$confirmation" != "y" ]] && [[ "$confirmation" != "yes" ]]; then
    echo "❌ Cancelled - database unchanged"
    return 1
  fi
  
  echo ""
  echo "💣 Initiating nuclear option..."
  
  # Get all tables first
  local tables=$(_pg_get_tables)
  if [[ -z "$tables" ]]; then
    echo "   No tables found to drop"
    return 0
  fi
  
  # Count tables
  local table_count=$(echo "$tables" | wc -l | tr -d ' ')
  echo "   Found $table_count tables to destroy..."
  echo ""
  
  # Build a single DROP command for all tables
  local drop_sql="DROP TABLE IF EXISTS "
  local first=true
  
  while IFS= read -r table; do
    [[ -z "$table" ]] && continue
    
    if [[ "$first" == "true" ]]; then
      drop_sql+="\"$table\""
      first=false
    else
      drop_sql+=", \"$table\""
    fi
  done <<< "$tables"
  
  drop_sql+=" CASCADE;"
  
  echo "   Dropping all tables with CASCADE..."
  
  # Execute the drop
  local result=$(_pg_execute "$drop_sql")
  local exit_code=$?
  
  if [[ $exit_code -eq 0 ]]; then
    echo "☠️  All tables have been dropped!"
    echo ""
    
    # Now drop other objects
    echo "   Dropping remaining objects..."
    
    # Drop all sequences that might remain
    local seq_sql="DROP SEQUENCE IF EXISTS "
    local sequences=$(_pg_execute "SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public';" "-tA" 2>/dev/null)
    if [[ -n "$sequences" ]]; then
      first=true
      while IFS= read -r seq; do
        [[ -z "$seq" ]] && continue
        if [[ "$first" == "true" ]]; then
          seq_sql+="\"$seq\""
          first=false
        else
          seq_sql+=", \"$seq\""
        fi
      done <<< "$sequences"
      seq_sql+=" CASCADE;"
      _pg_execute "$seq_sql" >/dev/null 2>&1
    fi
    
    # Drop all views
    local view_sql="DROP VIEW IF EXISTS "
    local views=$(_pg_execute "SELECT viewname FROM pg_views WHERE schemaname = 'public';" "-tA" 2>/dev/null)
    if [[ -n "$views" ]]; then
      first=true
      while IFS= read -r view; do
        [[ -z "$view" ]] && continue
        if [[ "$first" == "true" ]]; then
          view_sql+="\"$view\""
          first=false
        else
          view_sql+=", \"$view\""
        fi
      done <<< "$views"
      view_sql+=" CASCADE;"
      _pg_execute "$view_sql" >/dev/null 2>&1
    fi
    
    echo ""
    
    # Verify it's empty
    local remaining=$(_pg_get_tables 2>/dev/null)
    if [[ -z "$remaining" ]]; then
      echo "✅ Database is now completely empty!"
    else
      echo "⚠️  Some tables still remain (this shouldn't happen):"
      echo "$remaining" | sed 's/^/   /'
      echo ""
      echo "   Try running pg-nuke again or check for permission issues"
    fi
  else
    echo "❌ Failed to drop tables"
    echo "   Error details may be above"
  fi
}