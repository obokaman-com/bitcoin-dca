#!/bin/bash

# Bitcoin DCA Analyzer - Uninstall Script
# Usage: curl -fsSL https://raw.githubusercontent.com/obokaman-com/bitcoin-dca/main/uninstall.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.bitcoin-dca"
BIN_DIR="$HOME/.local/bin"
BIN_FILE="$BIN_DIR/btc-dca"

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

# Remove application files
remove_app_files() {
    print_status "Removing application files..."
    
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        print_success "Removed $INSTALL_DIR"
    else
        print_warning "Application directory not found: $INSTALL_DIR"
    fi
}

# Remove executable
remove_executable() {
    print_status "Removing executable..."
    
    if [ -f "$BIN_FILE" ]; then
        rm -f "$BIN_FILE"
        print_success "Removed $BIN_FILE"
    else
        print_warning "Executable not found: $BIN_FILE"
    fi
}

# Clean PATH entries (optional)
clean_path_entries() {
    print_warning "Note: This script does not automatically remove PATH entries from your shell configuration."
    print_status "If you manually added ~/.local/bin to your PATH, you may want to remove it from:"
    echo "  - ~/.bashrc"
    echo "  - ~/.zshrc"
    echo "  - Other shell configuration files"
}

# Show data preservation info
show_data_info() {
    if [ -d "$INSTALL_DIR/data" ] && [ -n "$(ls -A "$INSTALL_DIR/data" 2>/dev/null)" ]; then
        echo ""
        print_warning "User data detected!"
        echo "Do you want to preserve your Bitcoin price data and cache?"
        echo "  - Data location: $INSTALL_DIR/data"
        echo "  - Cache location: $INSTALL_DIR/.cache"
        
        read -p "Keep user data? [y/N]: " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Create backup directory
            BACKUP_DIR="$HOME/.bitcoin-dca-backup-$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            
            if [ -d "$INSTALL_DIR/data" ]; then
                cp -r "$INSTALL_DIR/data" "$BACKUP_DIR/"
                print_success "Data backed up to: $BACKUP_DIR/data"
            fi
            
            if [ -d "$INSTALL_DIR/.cache" ]; then
                cp -r "$INSTALL_DIR/.cache" "$BACKUP_DIR/"
                print_success "Cache backed up to: $BACKUP_DIR/.cache"
            fi
            
            echo ""
            print_status "To restore data after reinstalling:"
            echo "  cp -r $BACKUP_DIR/data ~/.bitcoin-dca/"
            echo "  cp -r $BACKUP_DIR/.cache ~/.bitcoin-dca/"
        fi
    fi
}

# Check if app is installed
check_installation() {
    if [ ! -d "$INSTALL_DIR" ] && [ ! -f "$BIN_FILE" ]; then
        print_error "Bitcoin DCA Analyzer does not appear to be installed."
        print_status "Installation directory: $INSTALL_DIR"
        print_status "Executable: $BIN_FILE"
        exit 1
    fi
}

# Main uninstall function
main() {
    echo ""
    echo "🗑️  Bitcoin DCA Analyzer - Uninstall Script"
    echo "=========================================="
    echo ""
    
    check_installation
    
    print_warning "This will completely remove Bitcoin DCA Analyzer from your system."
    echo "Files to be removed:"
    echo "  - Application: $INSTALL_DIR"
    echo "  - Executable: $BIN_FILE"
    echo ""
    
    read -p "Are you sure you want to uninstall? [y/N]: " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstall cancelled."
        exit 0
    fi
    
    # Handle data preservation
    show_data_info
    
    # Perform uninstall
    remove_app_files
    remove_executable
    clean_path_entries
    
    echo ""
    print_success "🎉 Bitcoin DCA Analyzer has been successfully uninstalled!"
    echo ""
    print_status "Thank you for using Bitcoin DCA Analyzer!"
    
    # Check if command still exists
    if command -v btc-dca >/dev/null 2>&1; then
        echo ""
        print_warning "The 'btc-dca' command may still be available in your current session."
        print_status "Please restart your terminal or run: hash -r"
    fi
}

# Run main function
main "$@"