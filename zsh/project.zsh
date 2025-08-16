# Project-specific Functions

# Source the service ports configuration
source ~/.config/zsh/service-ports.conf

# seePorts() - Display all service ports in a formatted table
# Purpose: Provides a quick overview of all configured ports across services
# How it works:
#   - Iterates through SERVICE_PORTS associative array
#   - Parses port configurations for each service
#   - Displays in a formatted table with all port types
# Usage: seePorts
seePorts() {
  # Ensure config is loaded
  source ~/.config/zsh/service-ports.conf
  
  echo "📊 Service Port Configuration"
  echo ""
  
  # Collect all unique port types across all services
  local all_port_types=()
  local service_data=()
  
  # First pass: collect all unique port types
  for service in "${(@k)SERVICE_PORTS}"; do
    local port_config="${SERVICE_PORTS[$service]}"
    for port_entry in ${(s:,:)port_config}; do
      local port_type="${port_entry%%:*}"
      if [[ ! " ${all_port_types[@]} " =~ " ${port_type} " ]]; then
        all_port_types+=("$port_type")
      fi
    done
  done
  
  # Sort port types for consistent display
  all_port_types=(${(o)all_port_types})
  
  # Prepare header
  local header_format="%-30s"
  local separator="=============================="
  for port_type in "${all_port_types[@]}"; do
    header_format+="  %-12s"
    separator+="  ============"
  done
  header_format+="\n"
  
  # Print header
  printf "$header_format" "SERVICE" "${(@U)all_port_types[@]}"
  printf "%-30s" "$separator"
  for port_type in "${all_port_types[@]}"; do
    printf "  %-12s" "============"
  done
  printf "\n"
  
  # Print each service's ports
  for service in ${(ok)SERVICE_PORTS[@]}; do
    local port_config="${SERVICE_PORTS[$service]}"
    local service_ports=()
    
    # Build associative array for this service's ports
    declare -A current_ports
    for port_entry in ${(s:,:)port_config}; do
      local port_type="${port_entry%%:*}"
      local port_value="${port_entry#*:}"
      current_ports[$port_type]="$port_value"
    done
    
    # Build row data matching the header order
    for port_type in "${all_port_types[@]}"; do
      if [[ -n "${current_ports[$port_type]}" ]]; then
        service_ports+=("${current_ports[$port_type]}")
      else
        service_ports+=("-")
      fi
    done
    
    # Print row
    printf "$header_format" "$service" "${service_ports[@]}"
  done
  
  echo ""
  echo "💡 Use 'setPort' to modify port configurations"
}

# setPort() - Interactive function to temporarily modify service ports
# Purpose: Allows users to easily update port configurations for any service
# How it works:
#   - Uses FZF for interactive service selection
#   - Shows current port configuration
#   - Prompts for port type and new value
#   - Temporarily modifies SERVICE_PORTS in memory
#   - Runs initPorts to apply changes to .env and docker files
#   - Restores SERVICE_PORTS to original reference values
# Usage: setPort
setPort() {
  # Ensure config is loaded
  source ~/.config/zsh/service-ports.conf
  
  # Check for FZF dependency
  if ! command -v fzf &> /dev/null; then
    echo "❌ FZF is required for interactive selection. Install with: brew install fzf"
    return 1
  fi
  
  # Select service
  local services=("${(@k)SERVICE_PORTS}")
  local selected_service=$(printf '%s\n' "${services[@]}" | sort | fzf --prompt="Select service: " --height=10 --reverse)
  
  if [[ -z "$selected_service" ]]; then
    echo "❌ No service selected"
    return 1
  fi
  
  echo "✅ Selected service: $selected_service"
  echo ""
  
  # Save original configuration
  local original_config="${SERVICE_PORTS[$selected_service]}"
  
  # Show current configuration
  echo "📋 Reference port configuration:"
  for port_entry in ${(s:,:)original_config}; do
    local port_type="${port_entry%%:*}"
    local port_value="${port_entry#*:}"
    echo "   ${port_type}: ${port_value}"
  done
  echo ""
  
  # Select port type to modify
  local port_types=()
  for port_entry in ${(s:,:)original_config}; do
    local port_type="${port_entry%%:*}"
    port_types+=("$port_type")
  done
  
  local selected_port_type=$(printf '%s\n' "${port_types[@]}" | fzf --prompt="Select port to modify: " --height=10 --reverse)
  
  if [[ -z "$selected_port_type" ]]; then
    echo "❌ No port type selected"
    return 1
  fi
  
  # Get current value
  local current_value
  for port_entry in ${(s:,:)original_config}; do
    local port_type="${port_entry%%:*}"
    local port_value="${port_entry#*:}"
    if [[ "$port_type" == "$selected_port_type" ]]; then
      current_value="$port_value"
      break
    fi
  done
  
  echo "✅ Modifying ${selected_port_type} port (reference: ${current_value})"
  echo ""
  
  # Prompt for new value
  echo -n "Enter new port value: "
  read new_port
  
  if [[ -z "$new_port" ]]; then
    echo "❌ No port value entered"
    return 1
  fi
  
  # Validate port is numeric
  if ! [[ "$new_port" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid port number: $new_port"
    return 1
  fi
  
  # Validate port range
  if (( new_port < 1 || new_port > 65535 )); then
    echo "❌ Port must be between 1 and 65535"
    return 1
  fi
  
  # Build new configuration
  local new_config=""
  for port_entry in ${(s:,:)original_config}; do
    local port_type="${port_entry%%:*}"
    local port_value="${port_entry#*:}"
    
    if [[ "$port_type" == "$selected_port_type" ]]; then
      port_value="$new_port"
    fi
    
    if [[ -n "$new_config" ]]; then
      new_config="${new_config},${port_type}:${port_value}"
    else
      new_config="${port_type}:${port_value}"
    fi
  done
  
  # Temporarily update SERVICE_PORTS in memory
  SERVICE_PORTS[$selected_service]="$new_config"
  echo "✅ Temporarily set ${selected_port_type} port to ${new_port}"
  echo ""
  
  # Show new configuration
  echo "📋 Modified port configuration for $selected_service:"
  for port_entry in ${(s:,:)new_config}; do
    local port_type="${port_entry%%:*}"
    local port_value="${port_entry#*:}"
    echo "   ${port_type}: ${port_value}"
  done
  echo ""
  
  # Ask if user wants to apply changes with initPorts
  echo -n "Apply changes to .env and docker files? (y/n): "
  read apply_changes
  
  if [[ "$apply_changes" == "y" ]] || [[ "$apply_changes" == "Y" ]]; then
    echo ""
    echo "🔧 Applying port changes to configuration files..."
    
    # Source services.sh to get the init functions
    local services_config="$HOME/.config/zsh/services.sh"
    if [ -f "$services_config" ]; then
      source "$services_config"
    else
      echo "❌ Services config not found at $services_config"
      # Restore original configuration
      SERVICE_PORTS[$selected_service]="$original_config"
      return 1
    fi
    
    # Call the appropriate initPorts function with the modified config
    # Try to call the corresponding initPorts function dynamically
    local init_function="initPorts-${selected_service}"
    if declare -f "$init_function" > /dev/null; then
      "$init_function" "$new_config"
    else
      echo "⚠️  No initPorts function found for $selected_service"
      echo "   Expected function name: $init_function"
    fi
    
    echo ""
    echo "✅ Port changes applied to .env and docker files"
  else
    echo "ℹ️  No changes applied to files."
  fi
  
  # Restore original SERVICE_PORTS configuration
  SERVICE_PORTS[$selected_service]="$original_config"
  echo ""
  echo "ℹ️  SERVICE_PORTS restored to reference values"
  echo "   The modified ports remain in your .env and docker files"
}

# link_memories() - Creates a symlink from git repo's memories folder to centralized location
# Purpose: Centralizes project memories/notes across multiple repositories
# How it works:
#   - If no path provided, detects the git repository root using 'git rev-parse --show-toplevel'
#   - If path provided, uses that path and extracts repo name from it
#   - Creates a directory in ~/memories-central/[repo-name]
#   - Creates a symlink from [repo]/memories → ~/memories-central/[repo-name]
# Dependencies:
#   - Git (for repository detection when no path provided)
#   - File system access to create directories and symlinks
# Use case: Centralizes project memories/notes across multiple repositories
link_memories() {
  local repo_root repo_name target
  
  # If path is provided as argument, use it; otherwise detect current repo
  if [ $# -eq 1 ]; then
    repo_root="$1"
  else
    repo_root=$(git rev-parse --show-toplevel) || {
      echo "❌ Not inside a Git repo."
      return 1
    }
  fi

  # Get the main worktree path
  # The main worktree is the one that is NOT detached and has no branch in parentheses
  # git worktree list shows: /path/to/main-repo SHA [branch]
  # For worktrees: /path/to/worktree SHA (branch)
  local main_worktree
  main_worktree=$(cd "$repo_root" 2>/dev/null && git worktree list 2>/dev/null | grep -v '(' | head -n1 | awk '{print $1}')
  
  # If we can't find a non-detached worktree, just take the first one
  if [ -z "$main_worktree" ]; then
    main_worktree=$(cd "$repo_root" 2>/dev/null && git worktree list 2>/dev/null | head -n1 | awk '{print $1}')
  fi
  
  if [ -n "$main_worktree" ]; then
    repo_name=$(basename "$main_worktree")
  else
    # Fallback to current repo basename
    repo_name=$(basename "$repo_root")
  fi

  target="$HOME/memories-central/$repo_name"

  mkdir -p "$target"

  ln -sfn "$target" "$repo_root/memories"
  echo "✅ Linked: $repo_root/memories → $target"
}


# Worktree Functions

# wtinit() - Creates a new git worktree with automatic setup and memories linking
# Purpose: Streamlined workflow for creating feature branches with isolated working directories
# Usage: wtinit <branch-name> [c]
#   - Default: Creates branch from latest origin/master or origin/main (fetches first)
#   - With 'c': Creates branch from current HEAD
# How it works:
#   - Takes a branch name as argument, optional 'c' flag for current branch
#   - Detects git repository root and name
#   - Creates worktree in parallel directory: [parent]/[repo-name]-[branch-name]
#   - Creates branch and worktree using 'git worktree add -b'
#   - Links memories folder to centralized location
#   - Opens the worktree in Cursor editor
#   - Sources and runs project-specific setup from ~/.config/zsh/services.sh
# Dependencies:
#   - Git with worktree support
#   - Cursor editor
#   - Optional: Setup functions in ~/.config/zsh/services.sh
#   - Memories directory structure
# Use case: Streamlined workflow for creating feature branches with isolated working directories
wtinit() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: wtinit <new-branch-name> [c]"
    echo "       'c' = create from current branch (default: from updated master/main)"
    return 1
  fi

  local feature_branch=$1
  local from_current=$2

  echo "📍 Current dir: $(pwd)"
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [ -z "$repo_root" ] || [ ! -d "$repo_root" ]; then
    echo "❌ Not inside a valid Git repo."
    return 1
  fi

  echo "📁 Detected repo root: $repo_root"
  local repo_name
  
  # Get the main worktree (original repo) path to extract base name
  local main_worktree
  main_worktree=$(git worktree list | head -n1 | awk '{print $1}')
  
  if [ -n "$main_worktree" ]; then
    repo_name=$(basename "$main_worktree")
  else
    # Fallback to current repo basename
    repo_name=$(basename "$repo_root")
  fi
  
  echo "🔍 Repo name: $repo_name"

  # Derive final path for worktree
  local parent_dir
  parent_dir=$(dirname "$repo_root")
  local worktree_path="${parent_dir}/${repo_name}-${feature_branch##*/}"

  echo "📂 Worktree path to be created: $worktree_path"
  
  # Handle branch creation based on flag
  if [ "$from_current" = "c" ]; then
    echo "🌿 Creating new branch from current HEAD..."
    local current_branch=$(git branch --show-current)
    echo "   Branching from: $current_branch"
    
    # Create worktree from current HEAD
    if git worktree add -b "$feature_branch" "$worktree_path"; then
      echo "✅ Git worktree created from $current_branch."
    else
      echo "❌ git worktree add failed!"
      return 1
    fi
  else
    # Default: create from updated master/main
    echo "🌿 Creating new branch from updated master/main..."
    
    # Determine main branch name (master or main)
    local main_branch
    if git show-ref --verify --quiet refs/heads/main; then
      main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
      main_branch="master"
    else
      echo "❌ Neither 'main' nor 'master' branch found!"
      return 1
    fi
    
    echo "   Fetching latest changes..."
    git fetch origin "$main_branch" || {
      echo "⚠️  Failed to fetch from origin/$main_branch"
    }
    
    echo "   Branching from: origin/$main_branch"
    
    # Create worktree from origin/main or origin/master
    if git worktree add -b "$feature_branch" "$worktree_path" "origin/$main_branch"; then
      echo "✅ Git worktree created from origin/$main_branch."
    else
      echo "❌ git worktree add failed!"
      return 1
    fi
  fi

  # Validate path exists
  if [ ! -d "$worktree_path" ]; then
    echo "❌ Worktree directory not found after creation."
    return 1
  fi

  # Link memories using the refactored function
  link_memories "$worktree_path"
  
  # Copy CLAUDE.md files from main worktree
  cd "$worktree_path"
  copy-claude-memories
  cd - > /dev/null

  echo "🎉 Done! You can now work inside: $worktree_path"

  # Open Cursor
  echo "💻 Opening Cursor..."
  cursor "$worktree_path" &

  # Run project-specific setup from services.sh
  local services_config="$HOME/.config/zsh/services.sh"
  
  if [ -f "$services_config" ]; then
    echo "🔧 Running project initialization for $repo_name..."
    cd "$worktree_path"
    source "$services_config"
    
    # Call the full init (which does initPorts + install + build)
    init "$repo_name"
  else
    echo "❌ Services config not found at $services_config"
    echo "   This file should contain init functions for different projects."
  fi
}


# copy-claude-memories() - Copies CLAUDE.md files from main worktree to current worktree
# Purpose: Preserves project-specific Claude AI context across worktrees
# How it works:
#   - Gets the main worktree path using 'git worktree list'
#   - Copies CLAUDE.md and CLAUDE.local.md if they exist
#   - Used in wtinit after creating new worktrees
# Dependencies:
#   - Git worktree support
#   - CLAUDE.md files in main worktree
# Use case: Maintaining consistent AI context across feature branches
copy-claude-memories() {
  local original_worktree
  original_worktree=$(git worktree list | head -1 | awk '{print $1}')
  
  echo "🧠 Copying Claude memories..."
  if [ -f "$original_worktree/CLAUDE.md" ]; then
    cp "$original_worktree/CLAUDE.md" ./CLAUDE.md
    echo "  ✓ Copied CLAUDE.md"
  fi
  
  if [ -f "$original_worktree/CLAUDE.local.md" ]; then
    cp "$original_worktree/CLAUDE.local.md" ./CLAUDE.local.md
    echo "  ✓ Copied CLAUDE.local.md"
  fi
}


# Helper function to parse port configuration
# Usage: parse_ports "ui:8000,server:3000,postgres:5432" "server"
# Returns: 3000
parse_port() {
  local port_string="$1"
  local port_name="$2"
  
  echo "$port_string" | tr ',' '\n' | grep "^${port_name}:" | cut -d':' -f2
}

# Helper function to create .ports file from configuration
# Usage: create_ports_file "my-service-name" ["port_config_string"]
create_ports_file() {
  local service_name="$1"
  local port_config="${2:-${SERVICE_PORTS[$service_name]}}"
  
  if [ -z "$port_config" ]; then
    echo "⚠️  No port configuration found for $service_name"
    return 1
  fi
  
  echo "📝 Creating .ports file..."
  
  # Parse individual ports and create .ports file
  {
    for port_entry in ${(s:,:)port_config}; do
      local port_name="${port_entry%%:*}"
      local port_value="${port_entry#*:}"
      echo "${(U)port_name}_PORT=$port_value"
    done
  } > .ports
  
  echo "✅ Created .ports file with fixed ports"
  cat .ports
}

# list_repo_ports() - Scans ~/code for repos with .ports files and lists them in a table
# Purpose: Provides a quick overview of all ports used across local projects.
# How it works:
#   - Iterates through all directories in ~/code.
#   - Checks for a .git directory to identify repos.
#   - If a .ports file exists, it reads the file.
#   - It collects all port information.
#   - Finally, it prints a formatted table with repo names and their ports.
list_repo_ports() {
    # Turn off any shell tracing to prevent debug output
    { set +x; } 2>/dev/null
    
    # Source utils to get helper functions
    source ~/.config/zsh/utils.zsh
    
    local code_dir="$HOME/code"
    local repos_with_ports=()
    local all_headers=()
    local repo_ports=()

    # First pass: find all repos with .ports and collect all possible headers
    for repo_path in "$code_dir"/*; do
        # Check for .git directory (regular repo) or .git file (worktree)
        if [[ (-d "$repo_path/.git" || -f "$repo_path/.git") ]] && [[ -f "$repo_path/.ports" ]]; then
            repos_with_ports+=("$repo_path")
            while IFS='=' read -r key value; do
                # Extract header from 'KEY_PORT'
                header="${key%_PORT}"
                if [[ ! " ${all_headers[@]} " =~ " ${header} " ]]; then
                    all_headers+=("$header")
                fi
            done < "$repo_path/.ports"
        fi
    done

    # If no repos with .ports found, exit
    if [ ${#repos_with_ports[@]} -eq 0 ]; then
        echo "No repositories with a .ports file found in $code_dir"
        return
    fi

    # Second pass: gather data for the table
    local unsorted_repos=()
    
    for repo_path in "${repos_with_ports[@]}"; do
        local actual_name=$(basename "$repo_path")
        local base_name=$(cd "$repo_path" 2>/dev/null && get_base_repo_name 2>/dev/null)
        
        # Determine display name based on worktree status
        local display_name=""
        if [[ "$actual_name" != "$base_name" ]]; then
            # It's a worktree - show as "base_repo_(worktree_suffix)"
            # Extract the suffix after the base name
            local suffix="${actual_name#$base_name-}"
            display_name="${base_name}_(${suffix})"
        else
            # Regular repo
            display_name="$base_name"
        fi
        
        local current_ports=()
        local active_count=0
        
        # Read ports from .ports file into a fresh associative array
        # IMPORTANT: unset and redeclare to avoid carrying over values
        unset ports_map
        declare -A ports_map
        while IFS='=' read -r key value; do
            ports_map[${key%_PORT}]="$value"
        done < "$repo_path/.ports"

        # Build the ports array with status indicators
        for header in "${all_headers[@]}"; do
            # Check if this port exists in the current repo's ports_map
            if [[ -n "${ports_map[$header]}" ]]; then
                local port_value="${ports_map[$header]}"
                
                # Check if port is numeric and something is listening
                if [[ "$port_value" =~ ^[0-9]+$ ]]; then
                    # Valid port number - check if something is listening
                    if lsof -ti tcp:"$port_value" &>/dev/null; then
                        # Port is active - add green checkmark
                        current_ports+=("${port_value}✓")
                        ((active_count++))
                    else
                        # Port not active - add red X
                        current_ports+=("${port_value}✗")
                    fi
                else
                    # Not a valid port number - show as-is
                    current_ports+=("$port_value")
                fi
            else
                # Port not defined for this repo
                current_ports+=("n/a")
            fi
        done
        
        # Store with pipe delimiter and active count for sorting
        unsorted_repos+=("${active_count}|${display_name}|${(j:|:)current_ports}")
    done
    
    # Sort by active count (descending) and store in repo_ports
    for row in ${(On)unsorted_repos}; do
        # Remove the active count before storing
        repo_ports+=("${row#*|}")
    done

    # Prepare header line for printf with better padding
    local header_line="%-50s"  # Increased to 50 for even longer worktree names
    for header in "${all_headers[@]}"; do
        header_line+="  %-15s"
    done
    header_line+="\n"

    # Print table header
    printf "$header_line" "REPOSITORY" "${all_headers[@]}"
    
    # Print separator
    printf "%-50s" "=================================================="  # Increased separator
    for header in "${all_headers[@]}"; do
        printf "  %-15s" "==============="
    done
    printf "\n"

    # Print table rows
    for row in "${repo_ports[@]}"; do
        # Split on pipe to separate display name from ports
        local display_name="${row%%|*}"
        local ports_str="${row#*|}"
        # Split ports string by pipe delimiter
        local ports_array=("${(@s:|:)ports_str}")
        printf "$header_line" "$display_name" "${ports_array[@]}"
    done
}

# list_current_ports() - Shows ports configuration for the current repository/worktree
# Purpose: Quick view of current repo's port configuration with status indicators
# How it works:
#   - Detects current repository (handles worktrees)
#   - Reads .ports file from current directory
#   - Shows port status with ✓ (active) or ✗ (configured but not listening)
#   - Uses same formatting as list_repo_ports for consistency
list_current_ports() {
    # Turn off any shell tracing to prevent debug output
    { set +x; } 2>/dev/null
    
    # Source utils to get helper functions
    source ~/.config/zsh/utils.zsh
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    # Check if .ports file exists
    if [ ! -f ".ports" ]; then
        echo "❌ No .ports file found in current directory"
        echo "   Run 'initPorts' to set up port configuration"
        return 1
    fi
    
    # Get repository name
    local actual_name=$(basename $(pwd))
    local base_name=$(get_base_repo_name)
    
    # Determine display name based on worktree status
    local display_name=""
    if [[ "$actual_name" != "$base_name" ]]; then
        # It's a worktree - show as "base_repo_(worktree_suffix)"
        local suffix="${actual_name#$base_name-}"
        display_name="${base_name}_(${suffix})"
    else
        # Regular repo
        display_name="$base_name"
    fi
    
    # Collect all port headers from .ports file
    local all_headers=()
    while IFS='=' read -r key value; do
        # Extract header from 'KEY_PORT'
        header="${key%_PORT}"
        if [[ ! " ${all_headers[@]} " =~ " ${header} " ]]; then
            all_headers+=("$header")
        fi
    done < .ports
    
    # Read ports into associative array
    declare -A ports_map
    while IFS='=' read -r key value; do
        ports_map[${key%_PORT}]="$value"
    done < .ports
    
    # Build the ports array with status indicators
    local current_ports=()
    local active_count=0
    local total_valid_ports=0
    
    for header in "${all_headers[@]}"; do
        local port_value="${ports_map[$header]}"
        
        # Check if port is numeric and something is listening
        if [[ "$port_value" =~ ^[0-9]+$ ]]; then
            ((total_valid_ports++))
            # Valid port number - check if something is listening
            if lsof -ti tcp:"$port_value" &>/dev/null; then
                # Port is active - add green checkmark
                current_ports+=("${port_value}✓")
                ((active_count++))
            else
                # Port not active - add red X
                current_ports+=("${port_value}✗")
            fi
        else
            # Not a valid port number - show as-is
            current_ports+=("$port_value")
        fi
    done
    
    # Prepare header line for printf
    local header_line="%-50s"
    for header in "${all_headers[@]}"; do
        header_line+="  %-15s"
    done
    header_line+="\n"
    
    # Print table header
    printf "$header_line" "REPOSITORY" "${all_headers[@]}"
    
    # Print separator
    printf "%-50s" "=================================================="
    for header in "${all_headers[@]}"; do
        printf "  %-15s" "==============="
    done
    printf "\n"
    
    # Print the single row for current repo
    printf "$header_line" "$display_name" "${current_ports[@]}"
    
    # Print summary
    echo ""
    if [ $total_valid_ports -gt 0 ]; then
        echo "📊 Status: $active_count/$total_valid_ports ports active"
    fi
}




# get-unique-random-ports() - Generates N unique random ports
# Purpose: Reusable function for generating multiple unique random ports
# Arguments:
#   $1 - Number of ports to generate
# How it works:
#   - Calls get_free_port N times
#   - Ensures all ports are unique by incrementing duplicates
#   - Returns space-separated list of ports
# Usage: local ports=($(get-unique-random-ports 3))
get-unique-random-ports() {
  local count="${1:-1}"
  local ports=()
  local i
  
  # Generate initial ports
  for ((i = 1; i <= count; i++)); do
    ports[i]=$(get_free_port)
  done
  
  # Ensure uniqueness - simple approach: if duplicate found, increment
  for ((i = 2; i <= count; i++)); do
    local j
    for ((j = 1; j < i; j++)); do
      if [[ ${ports[i]} -eq ${ports[j]} ]]; then
        # Find the max port and add 1
        local max_port=${ports[1]}
        local k
        for ((k = 2; k <= ${#ports[@]}; k++)); do
          [[ ${ports[k]} -gt $max_port ]] && max_port=${ports[k]}
        done
        ports[i]=$((max_port + 1))
        # Restart the uniqueness check for this port
        i=$((i - 1))
        break
      fi
    done
  done
  
  # Return space-separated ports (Zsh arrays need proper expansion)
  local result=""
  for ((i = 1; i <= count; i++)); do
    result="${result}${ports[i]} "
  done
  echo "${result% }"  # Remove trailing space
}


# copyFile() - Copies a file from source to destination
# Purpose: Reusable function for copying files (e.g., .env.example to .env)
# Arguments:
#   $1 - Source file path
#   $2 - Destination file path
# Returns: 0 on success, 1 on failure
copyFile() {
  local src="$1"
  local dest="$2"
  
  if [[ -f "$src" ]]; then
    cp "$src" "$dest"
    echo "✅ Copied $src to $dest"
    return 0
  else
    return 1
  fi
}


# writeRandomPort() - Writes a random port to a file with a specific key=value format
# Purpose: Reusable function for updating port configurations in .env files
# Arguments:
#   $1 - File path to update
#   $2 - Key name (e.g., "PORT", "VITE_PORT")
#   $3 - Port number to write
# How it works:
#   - Uses sed to update existing key=value or appends if not found
#   - Handles macOS sed syntax with -i ''
# Returns: 0 on success, 1 on failure
writeRandomPort() {
  local file_path="$1"
  local key="$2"
  local port="$3"
  
  if [[ ! -f "$file_path" ]]; then
    echo "⚠️  $file_path not found"
    return 1
  fi
  
  # Check if key exists in file
  if grep -q "^${key}=" "$file_path"; then
    # Update existing key
    sed -i '' "s/^${key}=.*/${key}=${port}/" "$file_path"
  else
    # Append new key
    echo "${key}=${port}" >> "$file_path"
  fi
  
  echo "✅ Updated ${key} to ${port} in $file_path"
  return 0
}


# create-docker-compose-override() - Creates docker-compose.override.yml with port mapping
# Purpose: Reusable function for creating docker compose overrides with custom ports
# Arguments:
#   $1 - File path for docker-compose.override.yml
#   $2 - Service name
#   $3 - Host port
#   $4 - Container port (default: 5432)
# How it works:
#   - Creates a minimal docker-compose.override.yml
#   - Maps host port to container port for specified service
# Returns: 0 on success
create-docker-compose-override() {
  local file_path="$1"
  local service_name="$2"
  local host_port="$3"
  local container_port="${4:-5432}"
  
  cat > "$file_path" << EOF
services:
  ${service_name}:
    ports: !override
      - "${host_port}:${container_port}"
EOF
  
  echo "✅ Created $file_path with ${service_name} port ${host_port}:${container_port}"
  return 0
}





# worktrees_remove_all() - Removes all git worktrees except the main repository
# Purpose: Cleaning up multiple worktrees after feature development
# How it works:
#   - Detects main repository path
#   - Takes optional filter argument to remove specific worktrees
#   - Uses 'git worktree list --porcelain' to get all worktrees
#   - Removes each worktree with 'git worktree remove --force'
#   - Skips the main repository to prevent self-destruction
# Dependencies:
#   - Git with worktree support
#   - Shell utilities (awk)
# Use case: Cleaning up multiple worktrees after feature development
worktrees_remove_all() {
  local main_repo filter
  main_repo=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "❌ Not inside a Git repository."
    return 1
  }

  filter="$1"

  echo "🧹 Removing Git worktrees (excluding main repo at $main_repo)..."
  [ -n "$filter" ] && echo "🔎 Filtering by: $filter"

  git worktree list --porcelain | awk '/worktree /{print $2}' | while read wt; do
    if [ "$wt" != "$main_repo" ]; then
      if [ -z "$filter" ] || [[ "$wt" == *"$filter"* ]]; then
        echo "🗑️  Removing worktree: $wt"
        git worktree remove --force "$wt"
      fi
    fi
  done

  echo "✅ Worktree cleanup complete."
}
