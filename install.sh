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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists python3; then
        print_error "Python 3 is required but not installed. Please install Python 3 and try again."
        exit 1
    fi
    
    if ! command_exists pip3; then
        print_error "pip3 is required but not installed. Please install pip3 and try again."
        exit 1
    fi
    
    if ! command_exists git; then
        print_error "Git is required but not installed. Please install Git and try again."
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
    pip3 install -r requirements.txt --user >/dev/null 2>&1
    
    print_success "Dependencies installed!"
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
python3 -m bitcoin_dca.main "\$@"
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
        
        # Detect shell and update appropriate config file
        if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            print_status "Added to ~/.zshrc"
        elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            print_status "Added to ~/.bashrc"
        else
            print_warning "Unknown shell. Please manually add ~/.local/bin to your PATH."
        fi
        
        print_warning "Please restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    fi
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    if [ -f "$BIN_DIR/btc-dca" ] && [ -x "$BIN_DIR/btc-dca" ]; then
        print_success "Installation verified!"
        return 0
    else
        print_error "Installation verification failed!"
        return 1
    fi
}

# Main installation function
main() {
    echo ""
    echo "🚀 Bitcoin DCA Analyzer - Installation Script"
    echo "============================================="
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