#!/bin/bash

# Adapted from a script provided by aloksharma
# url: https://community.bitwarden.com/t/guide-automating-bitwarden-updates-on-linux-deb-package/82232

# Credit: https://github.com/initsuj/rpm-bitwarden-bash-updater

# Define variables
DOWNLOAD_PAGE="https://bitwarden.com/download/?app=desktop&platform=linux&variant=rpm"
DOWNLOAD_DIR="/tmp"
BITWARDEN_RPM="$DOWNLOAD_DIR/bitwarden-latest.rpm"

echo "🔍 Checking the installed Bitwarden version..."

# Get the installed Bitwarden version from dpkg
INSTALLED_VERSION=$(rpm -qi bitwarden | grep -i "Version" | awk '{print $3}' | tr -d '\r')

# If Bitwarden is not installed, assume it needs to be installed
if [[ -z "$INSTALLED_VERSION" ]]; then
    echo "⚠️ Bitwarden is not installed. Proceeding with installation..."
else
    echo "✅ Installed Bitwarden version: $INSTALLED_VERSION"
fi

# Fetch the final redirected URL from Bitwarden's official download page
echo "🔍 Fetching the latest Bitwarden version from the official website..."
REDIRECTED_URL=$(curl -sI "$DOWNLOAD_PAGE" | grep -i "location" | awk '{print $2}' | tr -d '\r')

# Extract the latest version from the URL
LATEST_VERSION=$(echo "$REDIRECTED_URL" | grep -oP 'Bitwarden-\K[0-9]+\.[0-9]+\.[0-9]+(?=-x86_64.rpm)')

# Ensure we successfully retrieved the latest version number
if [[ -z "$LATEST_VERSION" ]]; then
    echo "❌ Failed to fetch the latest Bitwarden version. The website structure may have changed."
    exit 1
fi

echo "✅ Latest Bitwarden version: $LATEST_VERSION"

# Check if an update is needed
if [[ "$INSTALLED_VERSION" == "$LATEST_VERSION" ]]; then
    echo "👍 Bitwarden is already up to date. No update needed."
    exit 0
fi

echo "⬇️ Downloading Bitwarden $LATEST_VERSION..."
wget -O "$BITWARDEN_RPM" "$REDIRECTED_URL"

# Check if the download was successful
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to download Bitwarden. Please check your internet connection."
    exit 1
fi

echo "✅ Download completed. Installing Bitwarden..."

# Install the package
sudo rpm -i "$BITWARDEN_RPM"

echo "🎉 Bitwarden has been updated successfully!"

# Cleanup
rm -f "$BITWARDEN_DEB"
