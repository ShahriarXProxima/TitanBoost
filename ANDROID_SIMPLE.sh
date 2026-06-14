#!/bin/bash
# Ultra-Simple Android Installation Guide

cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════════╗
║            📱 INSTALL TITANBOOST ON ANDROID - SUPER SIMPLE              ║
╚══════════════════════════════════════════════════════════════════════════╝


STEP 1️⃣  - OPEN PLAY STORE & INSTALL TERMUX
═══════════════════════════════════════════════════════════════════════════

   1. Unlock your phone
   2. Open "Play Store" app
   3. Search box: type "Termux"
   4. Click the first result
   5. Tap blue "Install" button
   6. Wait... it's installing (2-3 minutes)
   7. Tap "Open" when done


STEP 2️⃣  - OPEN TERMUX
═══════════════════════════════════════════════════════════════════════════

   1. Look for Termux icon (black terminal icon)
   2. Tap it
   3. Wait for "Welcome to Termux!" message
   4. You'll see a $ prompt (ready to type)


STEP 3️⃣  - COPY THE MAGIC COMMAND
═══════════════════════════════════════════════════════════════════════════

   This ONE command installs everything:

   ┌────────────────────────────────────────────────────────────────┐
   │ pkg install git && git clone                                   │
   │ https://github.com/YOUR-USERNAME/TitanBoost.git &&           │
   │ cd TitanBoost && sh install-termux.sh && titanboost           │
   └────────────────────────────────────────────────────────────────┘

   ⚠️  Replace YOUR-USERNAME with your GitHub username!
   Example: https://github.com/john123/TitanBoost.git


STEP 4️⃣  - PASTE IN TERMUX
═══════════════════════════════════════════════════════════════════════════

   1. Long press (hold) in the Termux black area
   2. Select "Paste" from menu
   3. You'll see the command appear
   4. Press ENTER key
   5. Wait for installation (1-2 minutes)


STEP 5️⃣  - MENU APPEARS!
═══════════════════════════════════════════════════════════════════════════

   When done, you'll see:

      PROFILES:
      1. balanced         Conservative optimization
      2. gaming           Gaming performance
      3. extreme          Maximum performance

      Type: 1, 2, or 3


STEP 6️⃣  - CHOOSE YOUR MODE
═══════════════════════════════════════════════════════════════════════════

   Type one of these:
      1    → For daily use (balanced)
      2    → For gaming (extra performance)
      3    → For benchmark (maximum)

   Press ENTER
   Done! The optimization applies immediately! ✅


THAT'S IT! 🎉
═══════════════════════════════════════════════════════════════════════════

Every time you want to use it:
   • Open Termux
   • Type: titanboost
   • Choose 1, 2, or 3


DIRECT COMMANDS (Optional):
═══════════════════════════════════════════════════════════════════════════

You can also type these directly:

   titanboost balanced    ← Apply balanced mode
   titanboost gaming      ← Apply gaming mode
   titanboost extreme     ← Apply extreme mode
   titanboost info        ← Device info
   titanboost health      ← Check temperature
   titanboost clean       ← Free up RAM
   titanboost log         ← See what happened


SCREENSHOTS (What To See):
═══════════════════════════════════════════════════════════════════════════

Screen 1: Play Store
   [Search "Termux" → Find it → Click Install]

Screen 2: Termux Opens
   [Black terminal screen → Type command]

Screen 3: Installation Running
   [Text scrolling → Shows progress → Takes 1-2 min]

Screen 4: Menu Appears
   [Shows PROFILES options → Type 1, 2, or 3]

Screen 5: Done!
   [✓ Profile applied → Run anytime]


HELP IF STUCK:
═══════════════════════════════════════════════════════════════════════════

✗ "git: command not found"
  → Run: pkg install git

✗ "Permission denied"
  → Run: chmod +x install-termux.sh

✗ "No internet"
  → Check WiFi or mobile data connection

✗ Download as ZIP instead:
  → Visit: https://github.com/YOUR-USERNAME/TitanBoost
  → Click green "Code" → Download ZIP
  → Extract → cd TitanBoost-main → sh install-termux.sh


═══════════════════════════════════════════════════════════════════════════

Ready? Just 6 steps! Let's go! 🚀

EOF

