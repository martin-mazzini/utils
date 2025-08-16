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
  
  # Get clipboard content based on OS
  if command -v pbpaste &>/dev/null; then
    # macOS
    clipboard_content=$(pbpaste)
  elif command -v xclip &>/dev/null; then
    # Linux with xclip
    clipboard_content=$(xclip -selection clipboard -o)
  elif command -v xsel &>/dev/null; then
    # Linux with xsel
    clipboard_content=$(xsel --clipboard --output)
  else
    echo "❌ No clipboard utility found (pbpaste, xclip, or xsel)"
    return 1
  fi
  
  # Check if clipboard is empty
  if [ -z "$clipboard_content" ]; then
    echo "❌ Clipboard is empty"
    return 1
  fi
  
  # Pretty print JSON with jq
  if command -v jq &>/dev/null; then
    echo "$clipboard_content" | jq -C '.' 2>/dev/null || {
      echo "❌ Invalid JSON in clipboard"
      return 1
    }
  else
    echo "❌ jq is not installed. Install it with: brew install jq"
    return 1
  fi
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