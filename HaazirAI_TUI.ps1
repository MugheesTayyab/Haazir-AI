# ==============================================================================
# Haazir-AI — Terminal User Interface (TUI)
# Theme: Light Cozy & Minimalist
# ==============================================================================

# Ensure UTF-8 support for box-drawing characters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ── Color Palette (ANSI) ──────────────────────────────────────────────────────
$ESC = [char]27
$PALETTE = @{
    Reset      = "$ESC[0m"
    BgCream    = "$ESC[48;5;255m"  # Warm Off-White
    FgCharcoal = "$ESC[38;5;236m"  # Soft Black
    FgSage     = "$ESC[38;5;108m"  # Calming Green
    FgRose     = "$ESC[38;5;181m"  # Dusty Rose
    FgSand     = "$ESC[38;5;223m"  # Beige Border
    Bold       = "$ESC[1m"
    Italic     = "$ESC[3m"
}

# ── Mock Data ─────────────────────────────────────────────────────────────────
$PROVIDERS = @(
    @{ Name = "Arshad Electrician"; Rating = "4.8★"; Price = "1500"; Area = "G-11" },
    @{ Name = "Zahid Plumber";     Rating = "4.6★"; Price = "1200"; Area = "F-10" },
    @{ Name = "AC Master Salman";  Rating = "4.9★"; Price = "2500"; Area = "E-7" }
)

# ── Global State ─────────────────────────────────────────────────────────────
$Messages = @()
$Traces   = @()
$CurrentStep = 0
$PipelineState = "IDLE" # IDLE, RUNNING, WAITING_CONFIRM, COMPLETE
$PendingProvider = $null

# ── Helper Functions ──────────────────────────────────────────────────────────
function Write-Cozy {
    param([string]$Text, [string]$Color = $PALETTE.FgCharcoal, [switch]$NoNewline)
    $output = "$($PALETTE.BgCream)$($Color)$($Text)$($PALETTE.Reset)"
    if ($NoNewline) { Write-Host $output -NoNewline } else { Write-Host $output }
}

function Set-Cursor {
    param([int]$X, [int]$Y)
    [Console]::SetCursorPosition($X, $Y)
}

function Draw-Frame {
    $width = [Console]::WindowWidth - 1
    $height = [Console]::WindowHeight - 2
    $split = [int]($width * 0.7)

    # Clear Screen with Cream BG
    Write-Host "$($PALETTE.BgCream)" -NoNewline
    for ($i = 0; $i -lt $height; $i++) {
        Set-Cursor 0 $i
        Write-Host (" " * $width) -NoNewline
    }

    # Draw Borders
    Set-Cursor 0 0
    Write-Cozy ("┌" + ("─" * ($split - 1)) + "┬" + ("─" * ($width - $split - 1)) + "┐") -Color $PALETTE.FgSand

    for ($i = 1; $i -lt ($height - 1); $i++) {
        Set-Cursor 0 $i; Write-Cozy "│" -Color $PALETTE.FgSand
        Set-Cursor $split $i; Write-Cozy "│" -Color $PALETTE.FgSand
        Set-Cursor $width $i; Write-Cozy "│" -Color $PALETTE.FgSand
    }

    Set-Cursor 0 ($height - 1)
    Write-Cozy ("└" + ("─" * ($split - 1)) + "┴" + ("─" * ($width - $split - 1)) + "┘") -Color $PALETTE.FgSand
}

function Update-Trace {
    $width = [Console]::WindowWidth - 1
    $split = [int]($width * 0.7)
    $xStart = $split + 2

    # Title
    Set-Cursor $xStart 1
    Write-Cozy "AGENT TRACE" -Color "$($PALETTE.FgRose)$($PALETTE.Bold)"
    
    $steps = @(
        "🔍 Discovery", "🧠 Intent", "⚖️ Ranking", "⏸ Pause", "🥊 Bargain", "📋 Booking"
    )

    for ($i = 0; $i -lt $steps.Count; $i++) {
        Set-Cursor $xStart (3 + ($i * 2))
        $color = if ($i -lt $CurrentStep) { $PALETTE.FgSage } elseif ($i -eq $CurrentStep) { $PALETTE.FgRose } else { $PALETTE.FgSand }
        Write-Cozy $steps[$i] -Color $color
    }
}

function Add-Message {
    param($Role, $Text)
    $global:Messages += @{ Role = $Role; Text = $Text }
    Draw-Messages
}

function Draw-Messages {
    $width = [Console]::WindowWidth - 1
    $split = [int]($width * 0.7)
    $yStart = 2

    # Clear chat area
    for ($i = $yStart; $i -lt ([Console]::WindowHeight - 4); $i++) {
        Set-Cursor 2 $i
        Write-Cozy (" " * ($split - 4))
    }

    # Draw last N messages
    $maxMsg = [Console]::WindowHeight - 8
    $startIdx = [Math]::Max(0, $global:Messages.Count - $maxMsg)
    
    for ($i = $startIdx; $i -lt $global:Messages.Count; $i++) {
        $m = $global:Messages[$i]
        Set-Cursor 2 ($yStart + ($i - $startIdx))
        if ($m.Role -eq "AI") {
            Write-Cozy "Haazir-AI: " -Color "$($PALETTE.FgSage)$($PALETTE.Bold)" -NoNewline
            Write-Cozy $m.Text
        } else {
            Write-Cozy "Aap: " -Color "$($PALETTE.FgRose)$($PALETTE.Bold)" -NoNewline
            Write-Cozy $m.Text
        }
    }
}

function Start-Thinking {
    param($Duration = 1000)
    Set-Cursor 2 ([Console]::WindowHeight - 4)
    Write-Cozy "Finding local pros" -Color $PALETTE.FgSage -NoNewline
    for ($i = 0; $i -lt 3; $i++) {
        Start-Sleep -m ($Duration / 3)
        Write-Cozy "." -Color $PALETTE.FgSage -NoNewline
    }
}

# ── Pipeline Logic ──────────────────────────────────────────────────────────
function Run-Pipeline {
    param($InputText)
    $global:PipelineState = "RUNNING"
    $global:CurrentStep = 0
    Update-Trace

    # Step 1: Crisis Detection
    $lower = $InputText.ToLower()
    if ($lower -match "leak|short circuit|aag|fire") {
        $global:CurrentStep = 5 # Skip to Booking
        Update-Trace
        Set-Cursor 2 ([Console]::WindowHeight - 5)
        Write-Cozy "🚨 SAFETY FIRST! Emergency auto-booking initiated." -Color "$($PALETTE.BgCream)$($PALETTE.FgSage)$($PALETTE.Bold)"
        Start-Sleep -s 1
        $p = $PROVIDERS[0]
        Add-Message "AI" "Emergency! $($p.Name) raste mein hain. Call: 0300-XXXXXXX"
        $global:PipelineState = "COMPLETE"
        return
    }

    # Step 2-4: Processing
    $global:CurrentStep = 1; Update-Trace; Start-Sleep -m 400
    $global:CurrentStep = 2; Update-Trace; Start-Sleep -m 400
    $global:CurrentStep = 3; Update-Trace; Start-Sleep -m 400

    # Step 5: Recommendation & Pause
    $global:PendingProvider = $PROVIDERS[0]
    Add-Message "AI" "Maine best match dhunda hai: $($global:PendingProvider.Name) ($($global:PendingProvider.Rating))."
    Add-Message "AI" "Price: Rs. $($global:PendingProvider.Price). Booking confirm karoon? (Type 'Haan' ya 'Ok')"
    
    $global:CurrentStep = 3
    $global:PipelineState = "WAITING_CONFIRM"
    Update-Trace
}

# ── Main Entry ────────────────────────────────────────────────────────────────
try {
    # Set Console Size if possible
    # $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(120, 40)
    
    [Console]::Clear()
    Draw-Frame
    Update-Trace
    Add-Message "AI" "Assalam-o-Alaikum! Main Haazir-AI hoon. Aaj kya madad karoon?"

    while ($true) {
        $height = [Console]::WindowHeight
        $yInput = $height - 2
        Set-Cursor 2 $yInput
        Write-Cozy "Haazir-AI | Aapki kya madad karoon? > " -Color "$($PALETTE.FgCharcoal)$($PALETTE.Italic)" -NoNewline
        
        # Clear input line
        $inputStart = 34
        Write-Cozy (" " * ([Console]::WindowWidth - $inputStart - 5)) -NoNewline
        Set-Cursor $inputStart $yInput
        
        $userInput = Read-Host
        if ($userInput -eq "exit") { break }
        if ([string]::IsNullOrWhiteSpace($userInput)) { continue }

        Add-Message "User" $userInput

        if ($global:PipelineState -eq "WAITING_CONFIRM") {
            $lower = $userInput.ToLower()
            if ($lower -match "haan|ok|yes|confirm") {
                $global:CurrentStep = 5; Update-Trace
                Start-Thinking
                Add-Message "AI" "Zabardast! Booking done. $($global:PendingProvider.Name) 30 mins mein pohanch jayenge."
                $global:PipelineState = "COMPLETE"
            } elseif ($lower -match "mehenga|sasta|discount") {
                $global:CurrentStep = 4; Update-Trace
                Add-Message "AI" "Theek hai, main unse baat karke Rs. 200 kam karwa liye hain. Ab confirm?"
            } else {
                Add-Message "AI" "Samajh nahi aaya. 'Haan' kahein ya batayein agar budget ka masla hai."
            }
        } else {
            Run-Pipeline $userInput
        }
    }
}
finally {
    Write-Host $PALETTE.Reset
    [Console]::Clear()
}
