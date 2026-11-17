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
