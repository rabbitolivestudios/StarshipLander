#!/bin/bash

#############################################
# ROCKET LANDER - iOS App Setup & Submission
# Run this script to build and submit your app
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           ROCKET LANDER - iOS App Setup & Submission          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

#############################################
# Step 1: Check Prerequisites
#############################################
echo -e "\n${YELLOW}[Step 1/8] Checking prerequisites...${NC}"

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}ERROR: Xcode is not installed.${NC}"
    echo "Please install Xcode from the Mac App Store."
    exit 1
fi
echo -e "${GREEN}✓ Xcode found${NC}"

# Check for CocoaPods
if ! command -v pod &> /dev/null; then
    echo -e "${YELLOW}Installing CocoaPods...${NC}"
    sudo gem install cocoapods
fi
echo -e "${GREEN}✓ CocoaPods found${NC}"

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}ERROR: Python 3 is not installed.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python 3 found${NC}"

# Check for fastlane
if ! command -v fastlane &> /dev/null; then
    echo -e "${YELLOW}Installing Fastlane...${NC}"
    sudo gem install fastlane
fi
echo -e "${GREEN}✓ Fastlane found${NC}"

#############################################
# Step 2: Generate App Icon
#############################################
echo -e "\n${YELLOW}[Step 2/8] Generating app icon...${NC}"

cd Scripts
python3 generate_icon.py
cd ..
echo -e "${GREEN}✓ App icon generated${NC}"

#############################################
# Step 3: Configure Your Information
#############################################
echo -e "\n${YELLOW}[Step 3/8] Configuring your information...${NC}"

# Check if already configured
if grep -q "YOUR_ADMOB_APP_ID" RocketLander/Info.plist 2>/dev/null; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  CONFIGURATION REQUIRED${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Before continuing, you need to set up the following:"
    echo ""
    echo "1. APPLE DEVELOPER ACCOUNT"
    echo "   - Go to: https://developer.apple.com/programs/enroll/"
    echo "   - Cost: \$99/year"
    echo "   - You'll get a TEAM ID after enrollment"
    echo ""
    echo "2. ADMOB ACCOUNT (for ad revenue)"
    echo "   - Go to: https://admob.google.com/"
    echo "   - Create an app and get your App ID and Ad Unit IDs"
    echo ""
    echo "Please enter your information:"
    echo ""

    # Get Apple Developer Team ID
    read -p "Enter your Apple Developer Team ID (10 characters, e.g., ABC123DEFG): " TEAM_ID

    # Get Bundle ID
    read -p "Enter your bundle ID (e.g., com.yourname.rocketlander): " BUNDLE_ID

    # Get AdMob App ID
    read -p "Enter your AdMob App ID (ca-app-pub-XXXX~YYYY): " ADMOB_APP_ID

    # Get AdMob Banner Ad Unit ID
    read -p "Enter your AdMob Banner Ad Unit ID (ca-app-pub-XXXX/YYYY): " BANNER_AD_ID

    # Get AdMob Interstitial Ad Unit ID
    read -p "Enter your AdMob Interstitial Ad Unit ID (ca-app-pub-XXXX/YYYY): " INTERSTITIAL_AD_ID

    # Get App Store Connect credentials
    read -p "Enter your Apple ID email: " APPLE_ID

    echo ""
    echo -e "${YELLOW}Updating configuration files...${NC}"

    # Update Info.plist with AdMob App ID
    sed -i '' "s|ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX|${ADMOB_APP_ID}|g" RocketLander/Info.plist

    # Update BannerAdView.swift with ad unit IDs
    sed -i '' "s|YOUR_BANNER_AD_UNIT_ID|${BANNER_AD_ID}|g" RocketLander/BannerAdView.swift
    sed -i '' "s|YOUR_INTERSTITIAL_AD_UNIT_ID|${INTERSTITIAL_AD_ID}|g" RocketLander/BannerAdView.swift
    sed -i '' "s|YOUR_ADMOB_APP_ID|${ADMOB_APP_ID}|g" RocketLander/BannerAdView.swift

    # Update project.pbxproj with Team ID and Bundle ID
    sed -i '' "s|DEVELOPMENT_TEAM = \"\"|DEVELOPMENT_TEAM = \"${TEAM_ID}\"|g" RocketLander.xcodeproj/project.pbxproj
    sed -i '' "s|com.yourname.RocketLander|${BUNDLE_ID}|g" RocketLander.xcodeproj/project.pbxproj

    # Save Apple ID for later use
    echo "${APPLE_ID}" > .apple_id

    echo -e "${GREEN}✓ Configuration updated${NC}"
else
    echo -e "${GREEN}✓ Already configured${NC}"
    APPLE_ID=$(cat .apple_id 2>/dev/null || echo "")
fi

#############################################
# Step 4: Install Dependencies
#############################################
echo -e "\n${YELLOW}[Step 4/8] Installing dependencies...${NC}"

pod install --repo-update
echo -e "${GREEN}✓ Dependencies installed${NC}"

#############################################
# Step 5: Setup Fastlane
#############################################
echo -e "\n${YELLOW}[Step 5/8] Setting up Fastlane...${NC}"

mkdir -p fastlane

cat > fastlane/Fastfile << 'FASTFILE_EOF'
default_platform(:ios)

platform :ios do
  desc "Build and upload to App Store Connect"
  lane :release do
    # Increment build number
    increment_build_number(xcodeproj: "RocketLander.xcodeproj")

    # Build the app
    build_app(
      workspace: "RocketLander.xcworkspace",
      scheme: "RocketLander",
      export_method: "app-store",
      clean: true
    )

    # Upload to App Store Connect
    upload_to_app_store(
      skip_metadata: false,
      skip_screenshots: true,
      force: true,
      precheck_include_in_app_purchases: false,
      submit_for_review: false,
      automatic_release: false
    )
  end

  desc "Build for testing"
  lane :build do
    build_app(
      workspace: "RocketLander.xcworkspace",
      scheme: "RocketLander",
      export_method: "development",
      clean: true
    )
  end
end
FASTFILE_EOF

cat > fastlane/Appfile << APPFILE_EOF
app_identifier("${BUNDLE_ID:-com.yourname.RocketLander}")
apple_id("${APPLE_ID:-your@email.com}")
team_id("${TEAM_ID:-XXXXXXXXXX}")
APPFILE_EOF

cat > fastlane/Deliverfile << 'DELIVERFILE_EOF'
# App Store Metadata
app_identifier ENV["APP_IDENTIFIER"]

# Automatically submit for review after upload
submit_for_review false

# App Information
name({
  "en-US" => "Rocket Lander"
})

subtitle({
  "en-US" => "Land the rocket safely!"
})

description({
  "en-US" => "Experience the thrill of landing a rocket on a platform in this addictive physics-based game!

Test your skills as you guide your rocket through the atmosphere and attempt a perfect landing on the designated platform. Control your thrust carefully - too much and you'll overshoot, too little and you'll crash!

FEATURES:
• Realistic physics-based rocket controls
• Challenging landing mechanics
• Score based on landing precision and fuel efficiency
• Simple one-touch controls - tap to fire engines
• High score tracking
• Beautiful space graphics

Can you master the art of rocket landing? Download now and find out!"
})

keywords({
  "en-US" => "rocket,lander,space,game,physics,landing,simulation,arcade,casual"
})

# Category
primary_category "GAMES"
secondary_category "GAMES_SIMULATION"

# Age Rating
app_rating_config_path "./fastlane/rating_config.json"

# Pricing
price_tier 0
DELIVERFILE_EOF

cat > fastlane/rating_config.json << 'RATING_EOF'
{
  "CARTOON_FANTASY_VIOLENCE": 0,
  "REALISTIC_VIOLENCE": 0,
  "PROLONGED_GRAPHIC_SADISTIC_REALISTIC_VIOLENCE": 0,
  "PROFANITY_CRUDE_HUMOR": 0,
  "MATURE_SUGGESTIVE": 0,
  "HORROR": 0,
  "MEDICAL_TREATMENT_INFO": 0,
  "ALCOHOL_TOBACCO_DRUGS": 0,
  "GAMBLING": 0,
  "SEXUAL_CONTENT_NUDITY": 0,
  "GRAPHIC_SEXUAL_CONTENT_NUDITY": 0,
  "UNRESTRICTED_WEB_ACCESS": 0,
  "GAMBLING_CONTESTS": 0
}
RATING_EOF

echo -e "${GREEN}✓ Fastlane configured${NC}"

#############################################
# Step 6: Build the App
#############################################
echo -e "\n${YELLOW}[Step 6/8] Building the app...${NC}"

xcodebuild -workspace RocketLander.xcworkspace \
    -scheme RocketLander \
    -configuration Release \
    -sdk iphoneos \
    -quiet \
    clean build

echo -e "${GREEN}✓ App built successfully${NC}"

#############################################
# Step 7: Create Privacy Policy
#############################################
echo -e "\n${YELLOW}[Step 7/8] Creating privacy policy...${NC}"

cat > privacy_policy.html << 'PRIVACY_EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Rocket Lander - Privacy Policy</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #333; }
        h2 { color: #666; margin-top: 30px; }
        p { line-height: 1.6; color: #444; }
    </style>
</head>
<body>
    <h1>Rocket Lander - Privacy Policy</h1>
    <p>Last updated: $(date +%Y-%m-%d)</p>

    <h2>Information We Collect</h2>
    <p>Rocket Lander collects minimal data to provide you with the best gaming experience:</p>
    <ul>
        <li><strong>Game Data:</strong> High scores are stored locally on your device.</li>
        <li><strong>Advertising Data:</strong> We use Google AdMob to display ads. AdMob may collect device identifiers and usage data to serve relevant ads.</li>
    </ul>

    <h2>Third-Party Services</h2>
    <p>This app uses Google AdMob for advertising. Please review Google's privacy policy at: <a href="https://policies.google.com/privacy">https://policies.google.com/privacy</a></p>

    <h2>Data Storage</h2>
    <p>All game data (high scores) is stored locally on your device and is not transmitted to any servers.</p>

    <h2>Children's Privacy</h2>
    <p>This app is suitable for all ages (4+). We do not knowingly collect personal information from children.</p>

    <h2>Contact Us</h2>
    <p>If you have any questions about this privacy policy, please contact us.</p>
</body>
</html>
PRIVACY_EOF

echo -e "${GREEN}✓ Privacy policy created (privacy_policy.html)${NC}"
echo -e "${YELLOW}  Note: Host this file online and add the URL to App Store Connect${NC}"

#############################################
# Step 8: Submit to App Store
#############################################
echo -e "\n${YELLOW}[Step 8/8] Ready to submit!${NC}"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    SUBMISSION INSTRUCTIONS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Your app is built and ready! To submit to the App Store:"
echo ""
echo "1. FIRST-TIME SETUP (only needed once):"
echo "   a. Go to App Store Connect: https://appstoreconnect.apple.com"
echo "   b. Click '+' to create a new app"
echo "   c. Enter the following:"
echo "      - Platform: iOS"
echo "      - Name: Rocket Lander"
echo "      - Primary Language: English"
echo "      - Bundle ID: Select your bundle ID"
echo "      - SKU: rocketlander001"
echo ""
echo "2. UPLOAD YOUR APP:"
echo "   Run this command:"
echo -e "   ${GREEN}fastlane release${NC}"
echo ""
echo "3. COMPLETE IN APP STORE CONNECT:"
echo "   - Add screenshots (use the iOS Simulator)"
echo "   - Set the privacy policy URL"
echo "   - Submit for review"
echo ""
echo "Would you like to submit now? (y/n)"
read -p "> " SUBMIT_NOW

if [[ "$SUBMIT_NOW" == "y" || "$SUBMIT_NOW" == "Y" ]]; then
    echo ""
    echo -e "${YELLOW}Starting submission process...${NC}"
    echo "You may be prompted for your Apple ID password."
    echo ""
    fastlane release
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                         COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Files created:"
echo "  - RocketLander.xcworkspace (open this in Xcode)"
echo "  - privacy_policy.html (host online for App Store)"
echo ""
echo "Next steps:"
echo "  1. Test on a real device using Xcode"
echo "  2. Take screenshots in iOS Simulator"
echo "  3. Upload to App Store Connect"
echo ""
