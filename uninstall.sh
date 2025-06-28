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

# Detect the correct Python and pip commands (same logic as install.sh)
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
        return 0
    fi
    
    return 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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

# Remove pip package
remove_pip_package() {
    print_status "Removing pip package..."
    
    # Detect Python commands first
    if ! detect_python_commands; then
        print_warning "Could not detect Python/pip commands"
        print_status "You may need to manually run: pip uninstall bitcoin-dca"
        return 1
    fi
    
    # Check if package is installed
    if $PIP_CMD show bitcoin-dca >/dev/null 2>&1; then
        if $PIP_CMD uninstall bitcoin-dca -y >/dev/null 2>&1; then
            print_success "Removed bitcoin-dca package via pip"
        else
            print_error "Failed to remove bitcoin-dca package via pip"
            print_status "Try manually: $PIP_CMD uninstall bitcoin-dca"
            return 1
        fi
    else
        print_warning "bitcoin-dca package not found in pip"
    fi
    
    # Also remove any leftover executable (in case of mixed installations)
    if [ -f "$BIN_FILE" ]; then
        rm -f "$BIN_FILE"
        print_status "Removed leftover executable: $BIN_FILE"
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
    # Detect Python commands for pip check
    detect_python_commands >/dev/null 2>&1
    
    local is_pip_installed=false
    local is_manual_installed=false
    
    # Check if pip package is installed
    if [ -n "$PIP_CMD" ] && $PIP_CMD show bitcoin-dca >/dev/null 2>&1; then
        is_pip_installed=true
    fi
    
    # Check if manual installation exists
    if [ -d "$INSTALL_DIR" ] || [ -f "$BIN_FILE" ]; then
        is_manual_installed=true
    fi
    
    if [ "$is_pip_installed" = false ] && [ "$is_manual_installed" = false ]; then
        print_error "Bitcoin DCA Analyzer does not appear to be installed."
        print_status "Checked for:"
        print_status "  - Pip package: bitcoin-dca"
        print_status "  - Installation directory: $INSTALL_DIR"
        print_status "  - Executable: $BIN_FILE"
        exit 1
    fi
    
    if [ "$is_pip_installed" = true ]; then
        print_status "Found pip-installed package: bitcoin-dca"
    fi
    
    if [ "$is_manual_installed" = true ]; then
        print_status "Found manual installation files"
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
    echo "Items to be removed:"
    echo "  - Pip package: bitcoin-dca (if installed)"
    echo "  - Application directory: $INSTALL_DIR"
    echo "  - Any leftover executables"
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
    remove_pip_package
    remove_app_files
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