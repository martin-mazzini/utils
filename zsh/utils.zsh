# Utility Functions

zfun() {
  # Define function descriptions
  declare -A func_desc=(
    # Git functions
    [gcm]="Git add all & commit"
    [gp]="Git push with auto upstream"
    [ghpr]="Create GitHub PR"
    [grebase]="Rebase onto master with backup"
    [gsq]="Squash branch commits"
    [gstash]="Interactive stash picker"
    [gu]="Interactive unstage files"
    [grevf]="Revert file to master"
    [grevc]="Revert commit interactively"
    [gtm]="Time machine - browse commits"
    [gtmb]="Return from time machine"
    [gdiff]="Download PR diffs"
    [gpr]="Open merged PR in browser"
    [gcheck]="Create stash checkpoint"
    [gbranch]="Interactive branch picker"
    [gnuke]="Hard reset - remove all changes"
    [gcb]="Create & checkout branch from master"
    [gcbc]="Create & checkout branch from current"
    [gst]="Stash all changes with name"
    [gmu]="Update local master & return to current branch"
    
    # Worktree functions
    [wtinit]="Create worktree with memories"
    [worktrees_remove_all]="Remove all worktrees"
    [link_memories]="Link memories folder"
    
    # Port/Process functions
    [kp]="Kill process on port(s)"
    [kap]="Kill ports from .ports file"
    [get_free_port]="Find random free port"
    
    # Service Dispatcher functions
    [init]="Full init: ports + install + build"
    [initPorts]="Configure service ports"
    [install]="Install service dependencies"
    [build]="Build service and run migrations"
    [run]="Run development server with hot reload"
    [docker-run]="Run Docker services (detached)"
    [docker-stop]="Stop Docker services (preserve data)"
    [docker-restart]="Restart Docker services"
    [docker-build-images]="Build Docker images only"
    [docker-rebuild]="Rebuild and recreate containers"
    [docker-delete]="Nuclear cleanup of Docker stack"
    
    # Utility functions
    [prettyjson]="Pretty print JSON from clipboard"
    [docker_nuke]="Remove all Docker resources"
    [sync-dotfiles]="Sync personal dotfiles"
    [backup-dotfiles]="Backup personal dotfiles to repo"
    [home]="Go to home directory"
    [editz]="Edit .zshrc with Cursor"
    [editc]="Edit Cursor settings.json"
    [editservices]="Edit services.sh configuration"
    [zfun]="Show all functions"
    [inspect]="Print function source code"
    [pngsave]="Save clipboard image to memories/screenshots"

  )
  
  # Get all functions from all module files
  local funcs=""
  for module in ~/.config/zsh/*.zsh; do
    funcs+=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*\(\)' "$module" | sed 's/().*//')
    funcs+=$'\n'
  done
  
  # Build formatted list for fzf
  local formatted_list=""
  while IFS= read -r func; do
    [[ -z "$func" ]] && continue
    # Trim whitespace from function name
    func=$(echo "$func" | xargs)
    local desc="${func_desc[$func]:-No description}"
    formatted_list="${formatted_list}$(printf "%-20s | %s" "$func" "$desc")\n"
  done <<< "$funcs"
  
  # Use fzf for interactive selection
  local selected=$(echo -e "$formatted_list" | sort | uniq | \
    fzf --ansi \
        --header="Functions (Enter to see usage, Ctrl-C to exit)" \
        --preview='func=$(echo {} | cut -d"|" -f1 | xargs); type "$func" 2>/dev/null | head -20' \
        --preview-window=right:50%:wrap)
  
  # If a function was selected, show its usage
  if [[ -n "$selected" ]]; then
    local func_name=$(echo "$selected" | cut -d'|' -f1 | xargs)
    echo ""
    echo "Function: $func_name"
    echo "Usage: Run '$func_name' in your terminal"
    echo ""
    type "$func_name" | head -20
  fi
}

kp() {
   if [ -z "$1" ]; then
      echo "Usage: kp <port-number> [port-number ...]"
      return 1
    fi
    
    for port in "$@"; do
      local pids
      pids=$(lsof -ti tcp:"$port" 2>/dev/null)
      if [ -z "$pids" ]; then
        echo "⚠️  No process found listening on port $port"
      else
        echo "$pids" | while read -r pid; do
          if [ -n "$pid" ]; then
            # Check if this is a Docker-related process - don't kill it!
            local process_info=$(ps -p "$pid" -o comm= 2>/dev/null)
            if [[ "$process_info" =~ [Dd]ocker ]]; then
              echo "⚠️  Skipping Docker process $pid on port $port (process: $process_info)"
            else
              echo "🔪 Killing process $pid on port $port..."
              kill -9 "$pid" 2>/dev/null
            fi
          fi
        done
      fi
    done
}

kap() {
  if [ ! -f ".ports" ]; then
    echo "❌ No .ports file found in current directory"
    return 1
  fi
  
  echo "🔍 Reading ports from .ports file..."
  
  # Source the .ports file to get the variables
  source .ports
  
  # Only kill UI and server ports - skip database/infrastructure ports
  local ports=()
  [ -n "$UI_PORT" ] && ports+=($UI_PORT)
  [ -n "$SERVER_PORT" ] && ports+=($SERVER_PORT)
  # Intentionally skip: POSTGRES_PORT, REDIS_PORT, PROMETHEUS_PORT, GRAFANA_PORT
  
  if [ ${#ports[@]} -eq 0 ]; then
    echo "❌ No UI or server ports found in .ports file"
    return 1
  fi
  
  echo "🎯 Killing processes on UI/server ports only: ${ports[@]}"
  echo "   (Skipping database/infrastructure ports for safety)"
  kp "${ports[@]}"
}

# get_base_repo_name() - Gets the base repository name for worktrees
# Purpose: Extract the actual repository name from a worktree path
# How it works:
#   - For regular repos, returns the repo name directly
#   - For worktrees, extracts the base repo name from git common directory
#   - Handles any repository naming conventions
# Returns: Base repository name (e.g., "my-project" even for worktree "my-project-feature-branch")
get_base_repo_name() {
  local repo_path="${1:-$(pwd)}"
  
  # Try to get git common directory (works for worktrees)
  local git_common_dir=$(cd "$repo_path" 2>/dev/null && git rev-parse --git-common-dir 2>/dev/null)
  
  if [ -n "$git_common_dir" ]; then
    # If it's a worktree, git_common_dir will point to the main repo's .git
    if [[ "$git_common_dir" == *"/.git" ]]; then
      # Extract base repo path
      local base_repo_path="${git_common_dir%/.git}"
      echo "$(basename "$base_repo_path")"
    else
      # Regular repo (git_common_dir is just ".git")
      echo "$(basename $(cd "$repo_path" && git rev-parse --show-toplevel 2>/dev/null))"
    fi
  else
    # Fallback to current directory name
    echo "$(basename "$repo_path")"
  fi
}

docker_nuke() {
  echo "🔥 Nuking all Docker containers, images, volumes, and networks..."

  docker container rm -f $(docker container ls -aq) 2>/dev/null
  docker image rm -f $(docker image ls -aq) 2>/dev/null
  docker volume rm -f $(docker volume ls -q) 2>/dev/null
  docker network rm $(docker network ls -q | grep -v '^bridge$\|^host$\|^none$') 2>/dev/null

  echo "✅ Docker fully nuked."
}

home() {
  cd ~
}

editz() {
  cursor ~/.config/zsh
}

editc() {
  cursor ~/Library/Application\ Support/Cursor/User/settings.json
}


editservices() {
  cursor ~/.config/zsh/services.sh
}


prettyjson() {
  local clipboard_content
  local path="$1"
  
  # Get clipboard content (macOS)
  clipboard_content=$(/usr/bin/pbpaste)
  
  # Check if clipboard is empty
  if [[ -z "$clipboard_content" ]]; then
    echo "❌ Clipboard is empty"
    return 1
  fi
  
  # Parse the JSON content
  local json_content=""
  local is_escaped=false
  
  # First try to parse as regular JSON
  if echo "$clipboard_content" | /opt/homebrew/bin/jq . >/dev/null 2>&1; then
    # It's valid JSON, use as-is
    json_content="$clipboard_content"
  elif [[ "$clipboard_content" == *\\\"* ]]; then
    # Might be escaped JSON, try to unescape
    local json_to_parse="$clipboard_content"
    
    # If it doesn't start and end with quotes, wrap it
    if [[ ! "$clipboard_content" =~ ^\".*\"$ ]]; then
      json_to_parse="\"$clipboard_content\""
    fi
    
    # Try to unescape
    json_content=$(echo "$json_to_parse" | /opt/homebrew/bin/jq -r . 2>/dev/null)
    
    if [[ -z "$json_content" ]] || ! echo "$json_content" | /opt/homebrew/bin/jq . >/dev/null 2>&1; then
      echo "❌ Failed to parse JSON"
      return 1
    fi
    
    is_escaped=true
    echo "📋 JSON parsed from string"
  else
    echo "❌ Invalid JSON in clipboard"
    return 1
  fi
  
  # If no path specified, just pretty print
  if [ -z "$path" ]; then
    echo "$json_content" | /opt/homebrew/bin/jq -C '.'
    return
  fi
  
  # Build jq query from path argument
  local jq_query=""
  
  # Convert our simplified syntax to jq syntax
  # Split by dots and process each part
  local PARTS
  IFS='.' PARTS=(${=path})
  
  # Handle the path starting from root
  local first=true
  for part in "${PARTS[@]}"; do
    if [[ "$part" =~ ^[0-9]+$ ]]; then
      # It's a number, treat as array index
      if [[ "$first" == "true" ]]; then
        # Array at root level
        jq_query=".[${part}]"
        first=false
      else
        jq_query="${jq_query}[${part}]"
      fi
    else
      # It's a property name
      if [[ "$first" == "true" ]]; then
        jq_query=".${part}"
        first=false
      else
        jq_query="${jq_query}.${part}"
      fi
    fi
  done
  
  # Execute the jq query
  echo "$json_content" | /opt/homebrew/bin/jq -C "$jq_query" 2>/dev/null || {
    echo "❌ Invalid path: $path"
    echo "   Query: $jq_query"
    return 1
  }
}

sync-dotfiles() {
  backup-dotfiles
}

get_free_port() {
  while :; do
    port=$((RANDOM % 10000 + 20000))  # use high ports to avoid common services
    if ! (echo "" > /dev/tcp/127.0.0.1/$port) >/dev/null 2>&1; then
      echo $port
      return
    fi
  done
}



inspect() {
  if [ -z "$1" ]; then
    echo "Usage: inspect <function-name>"
    echo "Example: inspect kp"
    return 1
  fi
  
  local func_name="$1"
  local found=false
  
  # Search for the function in all .zsh files
  for module in ~/.config/zsh/*.zsh; do
    # Check if function exists in this file
    if grep -q "^${func_name}()" "$module"; then
      found=true
      echo "📍 Function '$func_name' found in: $module"
      echo ""
      
      # Extract function code using sed (more reliable for function names with special chars)
      sed -n "/^${func_name}()/,/^[a-zA-Z_][a-zA-Z0-9_-]*()/{
        /^${func_name}()/p
        /^${func_name}()/!{
          /^[a-zA-Z_][a-zA-Z0-9_-]*()/!p
        }
      }" "$module"
      
      break
    fi
  done
  
  if [ "$found" = false ]; then
    echo "❌ Function '$func_name' not found in ~/.config/zsh/*.zsh files"
    echo ""
    echo "💡 Available functions:"
    # List all available functions
    for module in ~/.config/zsh/*.zsh; do
      grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*\(\)' "$module" | sed 's/().*//' | sed 's/^/   /'
    done | sort | uniq
  fi
}

pngsave() {
  if [ -z "$1" ]; then
    echo "Usage: pngsave <filename>"
    echo "Example: pngsave login-screen"
    return 1
  fi
  
  local screenshots_dir="./memories/screenshots"
  local name="$1"
  
  # Create directory if it doesn't exist
  if [ ! -d "$screenshots_dir" ]; then
    echo "📁 Creating $screenshots_dir directory..."
    mkdir -p "$screenshots_dir"
  fi
  
  # Add .png extension if not provided
  if [[ "$name" != *.png ]]; then
    name="${name}.png"
  fi
  
  local filename="$screenshots_dir/$name"
  
  # Save clipboard image using pngpaste (macOS)
  if command -v pngpaste &>/dev/null; then
    if pngpaste "$filename" 2>/dev/null; then
      echo "✅ Screenshot saved: $filename"
    else
      echo "❌ No image in clipboard or failed to save"
      return 1
    fi
  else
    echo "❌ pngpaste not installed. Install with: brew install pngpaste"
    return 1
  fi
}




# feature() - Creates a new feature documentation file from an Obsidian template
# Purpose: Quickly scaffold feature documentation with a consistent template
# How it works:
#   - Takes a feature name as argument
#   - Copies template from: /Users/martin/Documents/obsidian-vault/Second brain/Templates/Feature.md
#   - Creates ./memories/features/[feature-name].md
#   - Uses osascript (AppleScript) to handle macOS file permissions issues
#   - Adds a timestamp to the created file
# Dependencies:
#   - Obsidian vault with template at specific path
#   - macOS (uses osascript for file access)
#   - File system permissions to Documents folder
# Use case: Quickly scaffold feature documentation with a consistent template
feature() {
  if [ -z "$1" ]; then
    echo "Usage: feature <feature-name>"
    return 1
  fi
  
  local feature_name="$1"
  local template_path="/Users/martin/Documents/obsidian-vault/Second brain/Templates/Feature.md"
  local memories_dir="./memories/features"
  local target_file="$memories_dir/${feature_name}.md"
  
  # Check if template exists
  if [ ! -f "$template_path" ]; then
    echo "❌ Template not found at: $template_path"
    return 1
  fi
  
  # Create memories/features directory if it doesn't exist
  if [ ! -d "$memories_dir" ]; then
    echo "📁 Creating $memories_dir directory..."
    mkdir -p "$memories_dir"
  fi
  
  # Check if target file already exists
  if [ -f "$target_file" ]; then
    echo "⚠️  Feature file already exists: $target_file"
    echo "   Overwrite? (y/n): "
    read -r confirmation
    if [[ "$confirmation" != "y" ]]; then
      echo "❌ Cancelled."
      return 1
    fi
  fi
  
  # Function to select files with fzf
  select_files() {
    local dir="$1"
    local description="$2"
    local depth="$3"
    
    if [ ! -d "$dir" ]; then
      echo "📝 Note: $dir does not exist, skipping $description" >&2
      return
    fi
    
    echo "" >&2
    echo "📁 Select $description" >&2
    echo "   (Tab=select multiple, Enter=confirm, ESC=skip):" >&2
    
    local files
    if [ "$depth" = "1" ]; then
      # For codebase overviews, only list files directly in ./memories/
      files=$(find -L "$dir" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sed "s|^\./||" | sort)
    else
      # For subdirectories, list all .md files
      files=$(find -L "$dir" -type f -name "*.md" 2>/dev/null | sed "s|^\./||" | sort)
    fi
    
    if [ -z "$files" ]; then
      echo "   No files found in $dir" >&2
      return
    fi
    
    echo "$files" | fzf --multi --height=10 --layout=reverse --prompt="Select files> " --bind="esc:abort" --bind="tab:toggle+down"
  }
  
  # Function to select GitHub PRs and download diffs
  select_github_prs() {
    echo "" >&2
    echo "📁 Select GitHub PRs to include" >&2
    echo "   (Tab=select multiple, Enter=confirm, ESC=skip):" >&2
    
    local selected_prs
    selected_prs=$(gh pr list --state merged --limit 100 --json number,title,mergedAt,author \
      --jq '.[] | "\(.number)|\(.title)|\(.mergedAt[:10])|\(.author.login)"' 2>/dev/null | \
      sort -t'|' -k3 -r | \
      awk -F'|' '{printf "%-6s | %-10s | %-15s | %s\n", $1, $3, $4, $2}' | \
      fzf --multi --height=15 --layout=reverse \
          --preview 'gh pr view {1} --comments' \
          --preview-window=right:50%:wrap \
          --header "Select PRs (Tab for multiple)" \
          --bind="tab:toggle+down" \
          --bind="esc:abort")
    
    if [[ -z "$selected_prs" ]]; then
      return
    fi
    
    mkdir -p ./memories/prs
    local pr_files=""
    
    echo "$selected_prs" | while IFS= read -r pr_data; do
      local pr_number=$(echo "$pr_data" | awk '{print $1}')
      local pr_title=$(gh pr view "$pr_number" --json title -q .title | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9]/-/g' | \
        sed 's/-\+/-/g' | \
        sed 's/^-\|-$//g')
      
      local filename="memories/prs/${pr_title}.txt"
      echo "   Downloading PR #${pr_number} diff..." >&2
      gh pr diff "$pr_number" > "./$filename" 2>/dev/null
      
      if [ -n "$pr_files" ]; then
        pr_files+=$'\n'
      fi
      pr_files+="$filename"
    done
    
    echo "$pr_files"
  }
  
  # Select files from each category
  echo "🔍 Select pre-requisite files for the feature documentation..."
  
  local overview_files=$(select_files "./memories" "codebase overviews" "1")
  local feature_files=$(select_files "./memories/features" "prior related features" "2")
  local plan_files=$(select_files "./memories/plans" "implementation plans" "2")
  local pr_files=$(select_github_prs)
  
  # Copy template using osascript (works around macOS permissions)
  echo ""
  echo "📋 Reading feature template..."
  
  # Try using osascript to read the file content
  local content
  content=$(osascript -e "set theFile to POSIX file \"$template_path\"
    set fileHandle to open for access theFile
    set fileContent to read fileHandle
    close access fileHandle
    return fileContent" 2>/dev/null)
  
  if [ -z "$content" ]; then
    echo "❌ Cannot read template file. Trying direct copy..."
    # Last resort: try cp with full path
    if ! content=$(cat "$template_path" 2>/dev/null); then
      echo "❌ Failed to read template."
      echo ""
      echo "🔧 To fix this, grant terminal access to Documents folder:"
      echo "   1. Open System Preferences → Security & Privacy → Privacy"
      echo "   2. Select 'Files and Folders' on the left"
      echo "   3. Find your terminal app and check 'Documents Folder'"
      echo "   OR select 'Full Disk Access' and add your terminal"
      echo "   4. Restart your terminal"
      return 1
    fi
  fi
  
  # Process the template content and add selected files
  local updated_content=""
  local in_prereq_section=false
  
  while IFS= read -r line; do
    if [[ "$line" == "## 1. Pre-requisite reads:" ]]; then
      in_prereq_section=true
      updated_content+="$line"$'\n'
      updated_content+=$'\n'
      updated_content+="List all files under \`./memories/**\` to locate the following inputs. Some filenames may include small typos. Once found, read and extract relevant information from:"$'\n'
      updated_content+=$'\n'
      
      # Add codebase overviews
      updated_content+="- General codebase overviews (e.g., \`./memories/\`)"
      if [ -n "$overview_files" ]; then
        updated_content+=":"
        echo "$overview_files" | while IFS= read -r file; do
          updated_content+=" \`$file\`"
        done
      fi
      updated_content+=$'\n'
      
      # Add feature descriptions
      updated_content+="- Descriptions of prior related features (\`./memories/features/\`)"
      if [ -n "$feature_files" ]; then
        updated_content+=":"
        echo "$feature_files" | while IFS= read -r file; do
          updated_content+=" \`$file\`"
        done
      fi
      updated_content+=$'\n'
      
      # Add implementation plans
      updated_content+="- Implementation plans of prior related features (\`./memories/plans/\`)"
      if [ -n "$plan_files" ]; then
        updated_content+=":"
        echo "$plan_files" | while IFS= read -r file; do
          updated_content+=" \`$file\`"
        done
      fi
      updated_content+=$'\n'
      
      # Add PRs
      updated_content+="- Pull requests implementing similar features (\`./memories/prs/\`)"
      if [ -n "$pr_files" ]; then
        updated_content+=":"
        echo "$pr_files" | while IFS= read -r file; do
          updated_content+=" \`$file\`"
        done
      fi
      updated_content+=$'\n'
      
    elif [[ "$in_prereq_section" == true ]] && [[ "$line" == "## "* ]]; then
      in_prereq_section=false
      updated_content+="$line"$'\n'
    elif [[ "$in_prereq_section" == true ]] && [[ "$line" == "- "* ]]; then
      # Skip the original pre-requisite lines
      continue
    else
      updated_content+="$line"$'\n'
    fi
  done <<< "$content"
  
  # Write the updated content to the target file
  echo "$updated_content" > "$target_file"
  echo "" >> "$target_file"
  echo "Created at: $(date '+%Y-%m-%d %H:%M:%S')" >> "$target_file"
  
  echo "✅ Feature file created: $target_file"
  
  # Open the file in Cursor
  cursor "$target_file"
}

# implementcc: Launch Claude Code with /implementPlan slash command for selected plan
implementcc() {
  if [ ! -e ./memories/plans ]; then
    echo "Error: ./memories/plans doesn't exist"
    return 1
  fi
  if [ ! -d ./memories/plans ]; then
    echo "Error: ./memories/plans is not a directory or doesn't point to a valid directory"
    return 1
  fi

  local files
  files=$(find -L ./memories/plans -type f -name '*.md' 2>/dev/null)
  if [ -z "$files" ]; then
    echo "No .md files found in ./memories/plans"
    return 1
  fi

  local selected
  selected=$(echo "$files" | fzf \
      --header="Select plan file for /implementPlan (ENTER to confirm)" \
      --preview='cat {}' \
      --preview-window=right:50%:wrap)

  if [ -z "$selected" ]; then
    echo "No file selected"
    return 1
  fi

  # Extract filename without path and .md extension
  local filename
  filename=$(basename "$selected" .md)

  echo "Launching Claude Code with /implementPlan $filename..."

  # Launch Claude Code with implementPlan slash command
  claude "/implementPlan $filename"
}

# plancc: Launch Claude Code with /planFeature slash command for selected feature
plancc() {
  if [ ! -e ./memories/features ]; then
    echo "Error: ./memories/features doesn't exist"
    return 1
  fi
  if [ ! -d ./memories/features ]; then
    echo "Error: ./memories/features is not a directory or doesn't point to a valid directory"
    return 1
  fi

  local files
  files=$(find -L ./memories/features -type f -name '*.md' 2>/dev/null)
  if [ -z "$files" ]; then
    echo "No .md files found in ./memories/features"
    return 1
  fi

  local selected
  selected=$(echo "$files" | fzf \
      --header="Select feature file for /planFeature (ENTER to confirm)" \
      --preview='cat {}' \
      --preview-window=right:50%:wrap)

  if [ -z "$selected" ]; then
    echo "No file selected"
    return 1
  fi

  # Extract filename without path and .md extension
  local filename
  filename=$(basename "$selected" .md)

  echo "Launching Claude Code with /planFeature $filename..."

  # Launch Claude Code with planFeature slash command
  claude "/planFeature $filename"
}



pngclaude() {
  if [ -z "$1" ]; then
    echo "Usage: pngclaude <filename>"
    echo "Example: pngclaude login-screen"
    return 1
  fi
  
  local screenshots_dir="./memories/screenshots"
  local name="$1"
  
  # Create directory if it doesn't exist
  if [ ! -d "$screenshots_dir" ]; then
    echo "📁 Creating $screenshots_dir directory..."
    mkdir -p "$screenshots_dir"
  fi
  
  # Add .png extension if not provided
  if [[ "$name" != *.png ]]; then
    name="${name}.png"
  fi
  
  local filename="$screenshots_dir/$name"
  
  # Save clipboard image using pngpaste (macOS)
  if command -v pngpaste &>/dev/null; then
    if pngpaste "$filename" 2>/dev/null; then
      echo "✅ Screenshot saved: $filename"
    else
      echo "❌ No image in clipboard or failed to save"
      return 1
    fi
  else
    echo "❌ pngpaste not installed. Install with: brew install pngpaste"
    return 1
  fi
}



# implementcc: Launch Claude Code with /implementPlan slash command for selected plan
implementcc() {
  if [ ! -e ./memories/plans ]; then
    echo "Error: ./memories/plans doesn't exist"
    return 1
  fi
  if [ ! -d ./memories/plans ]; then
    echo "Error: ./memories/plans is not a directory or doesn't point to a valid directory"
    return 1
  fi

  local files
  files=$(find -L ./memories/plans -type f -name '*.md' 2>/dev/null)
  if [ -z "$files" ]; then
    echo "No .md files found in ./memories/plans"
    return 1
  fi

  local selected
  selected=$(echo "$files" | fzf \
      --header="Select plan file for /implementPlan (ENTER to confirm)" \
      --preview='cat {}' \
      --preview-window=right:50%:wrap)

  if [ -z "$selected" ]; then
    echo "No file selected"
    return 1
  fi

  # Extract filename without path and .md extension
  local filename
  filename=$(basename "$selected" .md)

  echo "Launching Claude Code with /implementPlan $filename..."

  # Launch Claude Code with implementPlan slash command
  claude "/implementPlan $filename"
}