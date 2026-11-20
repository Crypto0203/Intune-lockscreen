# ==============================================================================
# Better Lending Login Disclaimer - Permanent Setup Script
# Run this once in PowerShell as Administrator on any target PC
# ==============================================================================

Write-Host ">>> Configuring Better Lending Disclaimer to run continuously on every Restart / Logon / Unlock..." -ForegroundColor Cyan

# 1. Target Directory
$dir = "C:\BetterLending"
if (!(Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# 2. Save the LoginWarning.ps1 script
$scriptPath = "$dir\LoginWarning.ps1"
$scriptContent = @'
Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Better Lending - Logon Warning"
        Height="420" Width="670" 
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        WindowStyle="None"
        Topmost="True"
        Background="#001660">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="110"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="60"/>
        </Grid.RowDefinitions>

        <!-- Company Logo fetched directly from GitHub -->
        <Image Grid.Row="0"
               Width="90" Height="90"
               HorizontalAlignment="Center"
               Margin="0,10,0,5"
               Source="https://raw.githubusercontent.com/Crypto0203/Intune-lockscreen/main/logo.png"/>

        <!-- Message Box -->
        <Border Grid.Row="1" Margin="40,10" CornerRadius="10"
                BorderBrush="White" BorderThickness="2" Background="#001660">
            <ScrollViewer VerticalScrollBarVisibility="Auto">
                <TextBlock Margin="20"
                           Foreground="White"
                           FontSize="14"
                           TextWrapping="Wrap"
                           TextAlignment="Center"
                           VerticalAlignment="Stretch"
                           HorizontalAlignment="Stretch">
This computer system is for authorized use only. Users must use only approved
communication channels, as set forth in the Better Lending Acceptable Use Policy,
when conducting business-related communications. Users have no explicit or implicit
expectation of privacy.

Any or all uses of this system and all files on this system may be intercepted,
monitored, recorded, copied, audited, and inspected by management.

By continuing to use this system, you indicate your awareness of and consent to these
terms and conditions. DO NOT LOG IN if you do not agree with the conditions stated in
this warning. Unauthorized or improper use of this system may result in administrative
disciplinary action or criminal penalties.
                </TextBlock>
            </ScrollViewer>
        </Border>

        <!-- OK Button -->
        <Button x:Name="okBtn"
                Grid.Row="2"
                Width="100" Height="30"
                HorizontalAlignment="Center"
                Margin="0,10,0,20"
                Content="OK"/>
    </Grid>
</Window>
"@

$window = [Windows.Markup.XamlReader]::Parse($xaml)
$okButton = $window.FindName("okBtn")
$okButton.Add_Click({ $window.Close() })
$null = $window.ShowDialog()
'@
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force
Write-Host "[1/4] Script saved at: $scriptPath" -ForegroundColor Green

# 3. Create a silent VBS launcher (prevents black PowerShell CMD popup)
$vbsPath = "$dir\LaunchDisclaimer.vbs"
$vbsContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$scriptPath""", 0, False
"@
$vbsContent | Out-File -FilePath $vbsPath -Encoding ASCII -Force
Write-Host "[2/4] Silent launcher created at: $vbsPath" -ForegroundColor Green

# 4. Method A: Registry Run Key (Runs automatically for ALL users on every reboot/restart/login)
$runKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $runKey -Name "BetterLendingDisclaimer" -Value "wscript.exe `"$vbsPath`"" -Force
Write-Host "[3/4] Registry Startup key configured (Guaranteed on every restart)" -ForegroundColor Green

# 5. Method B: Scheduled Task for Workstation Unlock (Win + L) and Logon
$taskName = "BetterLending_GUI_Disclaimer"
$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Better Lending Logon Disclaimer</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>
        <![CDATA[
          <QueryList>
            <Query Id="0" Path="Security">
              <Select Path="Security">
                *[System[(EventID=4800 or EventID=4801)]]
              </Select>
            </Query>
          </QueryList>
        ]]>
      </Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <GroupId>S-1-5-32-545</GroupId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT5M</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>wscript.exe</Command>
      <Arguments>"$vbsPath"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$tempXml = "$env:TEMP\BL_Disclaimer_Task.xml"
$xml | Out-File -FilePath $tempXml -Encoding Unicode
schtasks /Create /TN $taskName /XML $tempXml /F | Out-Null
Remove-Item $tempXml -Force
Write-Host "[4/4] Scheduled task registered for Lock & Unlock events" -ForegroundColor Green

Write-Host "`n>>> SUCCESS! The disclaimer is now permanently configured!" -ForegroundColor Yellow
Write-Host "It will now automatically appear:" -ForegroundColor White
Write-Host "  1. Whenever the PC restarts and any user logs in" -ForegroundColor White
Write-Host "  2. Whenever the user locks (Win + L) and unlocks the screen" -ForegroundColor White
