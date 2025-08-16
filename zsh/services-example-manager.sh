# Service-specific functions for my-app-service
# This is a template/example implementation for any generic service

# Full init function for my-app-service (ports + install + build)
init-my-app-service() {
echo "🚀 Full initialization for my-app-service..."

initPorts-my-app-service

install-my-app-service

build-my-app-service

echo "✅ my-app-service initialization complete!"
}

# Install function for my-app-service
install-my-app-service() {
echo "📦 Installing my-app-service dependencies..."

# Example: Install Node.js dependencies
if [ -f "package.json" ]; then
  npm install
elif [ -f "requirements.txt" ]; then
  # Example: Install Python dependencies
  pip install -r requirements.txt
elif [ -f "Cargo.toml" ]; then
  # Example: Install Rust dependencies
  cargo build --release
else
  echo "   No recognized dependency files found (package.json, requirements.txt, Cargo.toml)"
fi
}

# Build function for my-app-service
build-my-app-service() {
echo "🔨 Building my-app-service..."

# Source the .ports file to get port configuration
if [ -f ".ports" ]; then
  source .ports
else
  echo "❌ .ports file not found. Run 'initPorts' first."
  return 1
fi

# Example: Build the application
if [ -f "package.json" ]; then
  npm run build
elif [ -f "requirements.txt" ]; then
  echo "   Python app - no build step needed"
elif [ -f "Cargo.toml" ]; then
  cargo build --release
fi

echo "✅ my-app-service build complete!"
}

# Run function for my-app-service
run-my-app-service() {
echo "🚀 Starting my-app-service..."

# Source the .ports file to get port configuration
if [ -f ".ports" ]; then
  source .ports
  echo "   UI running on: http://localhost:$UI_PORT"
  echo "   Server running on: http://localhost:$SERVER_PORT"
else
  echo "❌ .ports file not found. Run 'initPorts' first."
  return 1
fi

# Example: Start the development server
if [ -f "package.json" ]; then
  npm run dev
elif [ -f "requirements.txt" ]; then
  python app.py
elif [ -f "Cargo.toml" ]; then
  cargo run
else
  echo "❌ No recognized app entry point found"
  return 1
fi
}

# my-app-service port initialization
initPorts-my-app-service() {
# Source the project utilities
source ~/.config/zsh/project.zsh

# Source service ports config
source ~/.config/zsh/service-ports.conf

# Use provided port config or default from service-ports.conf
local port_config="${1}"
if [ -z "$port_config" ]; then
  port_config="${SERVICE_PORTS[my-app-service]}"
fi

echo "🔧 Setting up my-app-service ports:"
echo "   Port configuration: $port_config"

# Create .ports file with the configuration
create_ports_file "my-app-service" "$port_config"

echo "✅ Ports configured for my-app-service"
}

# Function to create ports file (helper function)
create_ports_file() {
local service_name="$1" 
local port_config="$2"

if [ -z "$service_name" ] || [ -z "$port_config" ]; then
  echo "❌ create_ports_file requires service_name and port_config"
  return 1
fi

echo "# Generated ports for $service_name" > .ports
echo "# Format: TYPE_PORT=port_number" >> .ports
echo "" >> .ports

# Parse port configuration and write to .ports file
IFS=',' read -ra PORT_PAIRS <<< "$port_config"
for pair in "${PORT_PAIRS[@]}"; do
  IFS=':' read -ra PARTS <<< "$pair"
  local port_type="${PARTS[0]}"
  local port_number="${PARTS[1]}"
  
  # Convert to uppercase and add _PORT suffix
  local var_name=$(echo "${port_type}_PORT" | tr '[:lower:]' '[:upper:]')
  echo "${var_name}=${port_number}" >> .ports
done

echo "" >> .ports
echo "# Usage: source .ports to load these variables" >> .ports
}

# Docker functions for my-app-service

# Build Docker images for my-app-service
build-images-my-app-service() {
echo "🏗️  Building my-app-service Docker images..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "❌ docker-compose.yml not found"
  return 1
fi

local project_name="my-app-service"

echo "   Project: $project_name"
echo "   Building images..."

docker-compose -p "$project_name" build

if [ $? -eq 0 ]; then
  echo "✅ Docker images built successfully"
else
  echo "❌ Failed to build Docker images"
  return 1
fi
}

# Rebuild my-app-service (full rebuild with recreation)
rebuild-my-app-service() {
echo "♻️  Rebuilding my-app-service (images and containers)..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "❌ docker-compose.yml not found"
  return 1
fi

local project_name="my-app-service"

echo "   Project: $project_name"
echo "   Rebuilding with --build --force-recreate..."

docker-compose -p "$project_name" up -d --build --force-recreate

if [ $? -eq 0 ]; then
  echo "✅ my-app-service rebuilt successfully"
else
  echo "❌ Failed to rebuild my-app-service"
  return 1
fi
}

# Start my-app-service Docker services
docker-run-my-app-service() {
echo "🚀 Starting my-app-service Docker services..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "❌ docker-compose.yml not found"
  return 1
fi

local project_name="my-app-service"

echo "   Project: $project_name"
echo "   Starting services in detached mode..."

docker-compose -p "$project_name" up -d

if [ $? -eq 0 ]; then
  echo "✅ my-app-service services started"
  
  # Show running services
  echo ""
  echo "📊 Running services:"
  docker-compose -p "$project_name" ps
else
  echo "❌ Failed to start my-app-service services"
  return 1
fi
}

# Restart my-app-service Docker services
restart-docker-my-app-service() {
echo "🔄 Restarting my-app-service Docker services..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "❌ docker-compose.yml not found"
  return 1
fi

local project_name="my-app-service"

echo "   Project: $project_name"
echo "   Restarting services..."

docker-compose -p "$project_name" restart

if [ $? -eq 0 ]; then
  echo "✅ my-app-service services restarted"
else
  echo "❌ Failed to restart my-app-service services"
  return 1
fi
}

# Stop my-app-service Docker services
stop-my-app-service() {
echo "⏹️  Stopping my-app-service Docker services..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "❌ docker-compose.yml not found"
  return 1
fi

local project_name="my-app-service"

echo "   Project: $project_name"
echo "   Stopping services (containers preserved)..."

docker-compose -p "$project_name" stop

if [ $? -eq 0 ]; then
  echo "✅ my-app-service services stopped"
else
  echo "❌ Failed to stop my-app-service services"
  return 1
fi
}

# Delete my-app-service Docker stack completely
delete-my-app-service() {
echo "🗑️  Deleting my-app-service stack completely..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "❌ docker-compose.yml not found"
  return 1
fi

local project_name="my-app-service"

echo "   Project: $project_name"
echo "   Removing containers, networks, and volumes..."

docker-compose -p "$project_name" down -v --remove-orphans

if [ $? -eq 0 ]; then
  echo "✅ my-app-service stack deleted"
else
  echo "❌ Failed to delete my-app-service stack"
  return 1
fi
}

# Restart my-app-service (rebuild and restart)
restart-my-app-service() {
echo "🔄 Restarting my-app-service..."

build-my-app-service || return 1

echo ""
echo "🚀 Starting development server..."
run-my-app-service
}

# Nuke and restart my-app-service (clean install)
nuke-my-app-service() {
echo "☢️  Nuking and restarting my-app-service..."

# Delete Docker resources
if [ -f "docker-compose.yml" ]; then
  delete-my-app-service
fi

# Clean dependencies
if [ -d "node_modules" ]; then
  echo "🗑️  Removing node_modules..."
  rm -rf node_modules
fi

if [ -d "venv" ] || [ -d ".venv" ]; then
  echo "🗑️  Removing Python virtual environment..."
  rm -rf venv .venv
fi

if [ -d "target" ]; then
  echo "🗑️  Removing Rust target directory..."
  rm -rf target
fi

# Reinstall and rebuild
echo ""
echo "🔄 Reinstalling from scratch..."
init-my-app-service
}

# Randomize ports for my-app-service
randomize-my-app-service() {
echo "🎲 Randomizing ports for my-app-service..."

# Source utils for get_free_port function
source ~/.config/zsh/utils.zsh

# Generate random ports
local ui_port=$(get_free_port)
local server_port=$(get_free_port)
local postgres_port=5432  # Keep database port fixed

echo "   New ports:"
echo "     UI: $ui_port"
echo "     Server: $server_port"
echo "     PostgreSQL: $postgres_port (unchanged)"

# Update .ports file
cat > .ports << EOF
# Generated ports for my-app-service
# Format: TYPE_PORT=port_number

UI_PORT=$ui_port
SERVER_PORT=$server_port
POSTGRES_PORT=$postgres_port

# Usage: source .ports to load these variables
EOF

echo "✅ Ports randomized and saved to .ports"
} 