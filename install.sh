#!/bin/bash

# Bitcoin DCA Analyzer - One-liner Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/obokaman-com/bitcoin-dca/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/obokaman-com/bitcoin-dca"
INSTALL_DIR="$HOME/.bitcoin-dca"
BIN_DIR="$HOME/.local/bin"

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect the correct Python and pip commands
detect_python_commands() {
    # Try different combinations to find matching python/pip pairs
    
    # Option 1: python3 + pip3
    if command_exists python3 && command_exists pip3; then
        python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
        pip_python_version=$(pip3 --version 2>/dev/null | grep -o "python [0-9]\+\.[0-9]\+" | cut -d' ' -f2)
        
        if [ "$python_version" = "$pip_python_version" ]; then
            PYTHON_CMD="python3"
            PIP_CMD="pip3"
            return 0
        fi
    fi
    
    # Option 2: python + pip
    if command_exists python && command_exists pip; then
        python_version=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
        pip_python_version=$(pip --version 2>/dev/null | grep -o "python [0-9]\+\.[0-9]\+" | cut -d' ' -f2)
        
        if [ "$python_version" = "$pip_python_version" ]; then
            PYTHON_CMD="python"
            PIP_CMD="pip"
            return 0
        fi
    fi
    
    # Option 3: python3 + python -m pip
    if command_exists python3; then
        if python3 -m pip --version >/dev/null 2>&1; then
            PYTHON_CMD="python3"
            PIP_CMD="python3 -m pip"
            return 0
        fi
    fi
    
    # Option 4: python + python -m pip
    if command_exists python; then
        if python -m pip --version >/dev/null 2>&1; then
            PYTHON_CMD="python"
            PIP_CMD="python -m pip"
            return 0
        fi
    fi
    
    # If nothing works, fall back to python3/pip3
    if command_exists python3 && command_exists pip3; then
        PYTHON_CMD="python3"
        PIP_CMD="pip3"
        python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
        pip_python_version=$(pip3 --version 2>/dev/null | grep -o "python [0-9]\+\.[0-9]\+" | cut -d' ' -f2)
        print_warning "Using potentially mismatched Python ($python_version) and pip ($pip_python_version)"
        return 0
    fi
    
    return 1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Detect Python and pip commands
    if ! detect_python_commands; then
        print_error "Python 3 and pip are required but not found."
        print_status "Please install Python 3.8+ and pip, then try again:"
        print_status "  macOS: brew install python3"
        print_status "  Ubuntu/Debian: sudo apt install python3 python3-pip"
        print_status "  CentOS/RHEL: sudo yum install python3 python3-pip"
        exit 1
    fi
    
    # Check Python version (need 3.8+ for TensorFlow)
    python_version=$($PYTHON_CMD -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if ! $PYTHON_CMD -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
        print_error "Python 3.8+ is required, but found Python $python_version"
        print_status "Please upgrade Python and try again:"
        print_status "  macOS: brew install python3"
        print_status "  Ubuntu/Debian: sudo apt install python3.8+"
        exit 1
    fi
    print_success "Python $python_version detected (using $PYTHON_CMD)"
    print_success "Pip detected (using $PIP_CMD)"
    
    # Check Git
    if ! command_exists git; then
        print_error "Git is required but not installed."
        print_status "Please install Git and try again:"
        print_status "  macOS: brew install git"
        print_status "  Ubuntu/Debian: sudo apt install git"
        print_status "  CentOS/RHEL: sudo yum install git"
        exit 1
    fi
    
    print_success "All prerequisites found!"
}

# Create directories
setup_directories() {
    print_status "Setting up directories..."
    
    # Remove existing installation if it exists
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Existing installation found. Removing..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Create directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    mkdir -p "$INSTALL_DIR/data"
    mkdir -p "$INSTALL_DIR/.cache"
    
    print_success "Directories created!"
}

# Download and install application
install_app() {
    print_status "Downloading Bitcoin DCA Analyzer..."
    
    # Clone the repository
    git clone "$REPO_URL" "$INSTALL_DIR/bitcoin-dca-tmp" >/dev/null 2>&1
    
    # Move files to install directory
    mv "$INSTALL_DIR/bitcoin-dca-tmp"/* "$INSTALL_DIR/"
    mv "$INSTALL_DIR/bitcoin-dca-tmp"/.* "$INSTALL_DIR/" 2>/dev/null || true
    rm -rf "$INSTALL_DIR/bitcoin-dca-tmp"
    
    print_success "Application downloaded!"
}

# Install Python dependencies
install_dependencies() {
    print_status "Installing Python dependencies..."
    
    cd "$INSTALL_DIR"
    
    # Try to install dependencies with better error handling
    if ! $PIP_CMD install -r requirements.txt --user --quiet; then
        print_error "Failed to install Python dependencies"
        print_status "This could be due to:"
        print_status "  - Missing system libraries (see error above)"
        print_status "  - Insufficient disk space"
        print_status "  - Network connectivity issues"
        print_status "  - Python version compatibility"
        print_status ""
        print_status "Try installing manually:"
        print_status "  $PIP_CMD install -r requirements.txt --user"
        print_status ""
        print_status "For TensorFlow issues on macOS with Apple Silicon:"
        print_status "  pip3 install tensorflow-macos --user"
        exit 1
    fi
    
    # Verify critical dependencies are importable
    if ! $PYTHON_CMD -c "import pandas, numpy, rich, click" 2>/dev/null; then
        print_error "Critical dependencies failed to import properly"
        print_status "Try running the application manually to see detailed error:"
        print_status "  cd $INSTALL_DIR && $PYTHON_CMD -m bitcoin_dca.main"
        exit 1
    fi
    
    print_success "Dependencies installed and verified!"
}

# Create executable script
create_executable() {
    print_status "Creating executable script..."
    
    cat > "$BIN_DIR/btc-dca" << EOF
#!/bin/bash
# Bitcoin DCA Analyzer - Global executable wrapper

# Change to app directory
cd "$INSTALL_DIR"

# Run the application with Python
$PYTHON_CMD -m bitcoin_dca.main "\$@"
EOF
    
    # Make it executable
    chmod +x "$BIN_DIR/btc-dca"
    
    print_success "Executable script created!"
}

# Update PATH if needed
update_path() {
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_warning "~/.local/bin is not in your PATH."
        print_status "Adding ~/.local/bin to your shell configuration..."
        
        # More robust shell detection
        current_shell=$(basename "$SHELL" 2>/dev/null || echo "unknown")
        config_file=""
        
        case "$current_shell" in
            "zsh")
                config_file="$HOME/.zshrc"
                ;;
            "bash")
                # Check for .bash_profile on macOS, .bashrc on Linux
                if [[ "$OSTYPE" == "darwin"* ]] && [ -f "$HOME/.bash_profile" ]; then
                    config_file="$HOME/.bash_profile"
                else
                    config_file="$HOME/.bashrc"
                fi
                ;;
            "fish")
                print_warning "Fish shell detected. Please manually add to your config:"
                print_status "  fish_add_path ~/.local/bin"
                return
                ;;
            *)
                print_warning "Unknown shell ($current_shell). Please manually add ~/.local/bin to your PATH."
                print_status "Add this line to your shell config file:"
                print_status "  export PATH=\"\$HOME/.local/bin:\$PATH\""
                return
                ;;
        esac
        
        if [ -n "$config_file" ]; then
            # Create config file if it doesn't exist
            touch "$config_file"
            
            # Check if PATH export already exists
            if ! grep -q "HOME/.local/bin" "$config_file" 2>/dev/null; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$config_file"
                print_success "Added to $config_file"
                print_warning "Please restart your terminal or run: source $(basename $config_file)"
            else
                print_status "PATH already configured in $config_file"
            fi
        fi
    else
        print_success "~/.local/bin is already in your PATH"
    fi
}

# Detect OS for better error messages
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "$NAME"
        else
            echo "Linux"
        fi
    else
        echo "$OSTYPE"
    fi
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check if executable exists and is executable
    if [ ! -f "$BIN_DIR/btc-dca" ]; then
        print_error "Executable not found: $BIN_DIR/btc-dca"
        return 1
    fi
    
    if [ ! -x "$BIN_DIR/btc-dca" ]; then
        print_error "Executable is not executable: $BIN_DIR/btc-dca"
        return 1
    fi
    
    # Try to run a quick test (just check if it starts)
    if ! "$BIN_DIR/btc-dca" --help >/dev/null 2>&1; then
        print_warning "Executable created but may have runtime issues"
        print_status "Try running manually to debug: $BIN_DIR/btc-dca"
    fi
    
    print_success "Installation verified!"
    return 0
}

# Main installation function
main() {
    echo ""
    echo "🚀 Bitcoin DCA Analyzer - Installation Script"
    echo "============================================="
    echo ""
    
    detected_os=$(detect_os)
    print_status "Detected OS: $detected_os"
    echo ""
    
    check_prerequisites
    setup_directories
    install_app
    install_dependencies
    create_executable
    update_path
    
    if verify_installation; then
        echo ""
        echo "🎉 Installation completed successfully!"
        echo ""
        echo "Usage:"
        echo "  btc-dca                    # Run the application"
        echo "  btc-dca --csv /path/file   # Use custom CSV file"
        echo "  btc-dca --help             # Show help"
        echo ""
        echo "Installation location: $INSTALL_DIR"
        echo "Executable location: $BIN_DIR/btc-dca"
        echo ""
        
        # Try to run a quick test if PATH is set up
        if command_exists btc-dca; then
            echo "✅ Ready to use! Try running: btc-dca"
        else
            echo "⚠️  Please restart your terminal or update your PATH to use 'btc-dca'"
        fi
        
    else
        echo ""
        echo "❌ Installation failed. Please check the error messages above."
        exit 1
    fi
}

# Run main function
main "$@"