<#
.SYNOPSIS
    ExplorerGroupManager.ps1
    Modern GUI to switch, customize, or disable File Explorer "Group By" behavior globally on Windows 10 & 11.
#>

# 1. STA Guard for PowerShell 7 (pwsh) and MTA runspaces
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne [System.Threading.ApartmentState]::STA) {
    if (Get-Command powershell.exe -ErrorAction SilentlyContinue) {
        & powershell.exe -NoProfile -STA -WindowStyle Hidden -File $PSCommandPath
        exit
    }
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Explorer View &amp; Group Manager" Height="530" Width="490"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Background="#161b22" Foreground="#e6edf3" FontFamily="Segoe UI">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#21262d"/>
            <Setter Property="Foreground" Value="#f0f6fc"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="42"/>
            <Setter Property="Margin" Value="0,0,0,10"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#30363d"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="border" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#30363d"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#58a6ff"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#161b22"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="22">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <StackPanel Grid.Row="0" Margin="0,0,0,16">
            <TextBlock Text="Explorer Group By Manager" FontSize="18" FontWeight="Bold" Foreground="#58a6ff"/>
            <TextBlock Text="Configure and toggle global File Explorer folder grouping behavior." FontSize="12" Foreground="#8b949e" Margin="0,4,0,0"/>
        </StackPanel>

        <!-- Status Card with Vector Indicator & Refresh Button -->
        <Border Grid.Row="1" Background="#1c2128" BorderBrush="#30363d" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,16">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                    <TextBlock Text="Current Status:" FontSize="11" Foreground="#8b949e"/>
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="0,4,0,0">
                        <Ellipse Name="dotStatus" Width="9" Height="9" Fill="#3fb950" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBlock Name="txtStatus" Text="Checking..." FontWeight="Bold" FontSize="13" Foreground="#3fb950" VerticalAlignment="Center"/>
                    </StackPanel>
                </StackPanel>
                <Button Grid.Column="1" Name="btnRefreshStatus" Height="28" Width="78" Margin="0" Background="#21262d" BorderBrush="#30363d" FontSize="11">
                    <TextBlock Text="Refresh" FontWeight="SemiBold"/>
                </Button>
            </Grid>
        </Border>

        <!-- Action Buttons -->
        <StackPanel Grid.Row="2">
            <!-- Disable Group By (None) -->
            <Button Name="btnDisableGroup" Background="#1b382b" BorderBrush="#238636" Height="44">
                <TextBlock Text="Disable Group By Globally (None)" FontWeight="Bold"/>
            </Button>

            <!-- Restore Windows Defaults -->
            <Button Name="btnRestoreDefault" Background="#382124" BorderBrush="#da3633" Height="44">
                <TextBlock Text="Restore Windows Default Grouping" FontWeight="Bold"/>
            </Button>

            <!-- Quick Modes Grid -->
            <Grid Margin="0,4,0,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="10"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Button Grid.Column="0" Name="btnGroupByDate" Content="Group by Date" Height="36"/>
                <Button Grid.Column="2" Name="btnGroupByName" Content="Group by Name (A-Z)" Height="36"/>
            </Grid>

            <Grid Margin="0,0,0,10">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="10"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Button Grid.Column="0" Name="btnGroupByType" Content="Group by File Type" Height="36"/>
                <Button Grid.Column="2" Name="btnRestartExplorer" Content="Restart Explorer" Height="36" Background="#21262d"/>
            </Grid>
        </StackPanel>

        <!-- Log / Output Console -->
        <Border Grid.Row="3" Background="#0d1117" BorderBrush="#21262d" BorderThickness="1" CornerRadius="6" Padding="10">
            <ScrollViewer Height="60" VerticalScrollBarVisibility="Auto">
                <TextBlock Name="txtLog" Text="Ready. Select an option above to apply changes." FontSize="11" Foreground="#8b949e" TextWrapping="Wrap"/>
            </ScrollViewer>
        </Border>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Elements
$txtStatus          = $window.FindName("txtStatus")
$dotStatus          = $window.FindName("dotStatus")
$txtLog             = $window.FindName("txtLog")
$btnRefreshStatus   = $window.FindName("btnRefreshStatus")
$btnDisableGroup    = $window.FindName("btnDisableGroup")
$btnRestoreDefault  = $window.FindName("btnRestoreDefault")
$btnGroupByDate     = $window.FindName("btnGroupByDate")
$btnGroupByName     = $window.FindName("btnGroupByName")
$btnGroupByType     = $window.FindName("btnGroupByType")
$btnRestartExplorer = $window.FindName("btnRestartExplorer")

# Registry Paths
$hklmFolderTypes = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes"
$hkcuFolderTypes = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes"
$hkcuAppKey      = "HKCU:\SOFTWARE\ExplorerGroupManager"
$hkcuShell       = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"
$hkcuBags        = "$hkcuShell\Bags"
$hkcuBagMRU      = "$hkcuShell\BagMRU"
$hkcuStreams     = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Defaults"

function Log-Msg {
    param([string]$m)
    $txtLog.Text = "[$((Get-Date).ToString('HH:mm:ss'))] $m`n" + $txtLog.Text
}

function Set-StatusView {
    param(
        [string]$Text,
        [System.Windows.Media.Brush]$Brush
    )
    $txtStatus.Text = $Text
    $txtStatus.Foreground = $Brush
    $dotStatus.Fill = $Brush
}

function Update-StatusUI {
    # 1. First check the app state key if available
    $savedMode = $null
    if (Test-Path $hkcuAppKey) {
        $appProp = Get-ItemProperty -Path $hkcuAppKey -ErrorAction SilentlyContinue
        if ($appProp -and $appProp.Mode) {
            $savedMode = $appProp.Mode.ToString()
        }
    }

    # 2. Check HKCU FolderTypes override
    if (Test-Path $hkcuFolderTypes) {
        # Check Downloads TopView (most explicit template in Windows)
        $dlPath = "$hkcuFolderTypes\{885a186e-a440-4ada-812b-db871b942259}\TopViews"
        $topViews = if (Test-Path $dlPath) { @(Get-ChildItem -Path $dlPath -ErrorAction SilentlyContinue) } else { @() }
        
        if ($topViews.Count -eq 0) {
            $topViews = @(Get-ChildItem -Path $hkcuFolderTypes -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSParentPath -like "*TopViews*" })
        }

        if ($topViews.Count -gt 0) {
            $prop = Get-ItemProperty -Path $topViews[0].PSPath -ErrorAction SilentlyContinue
            if ($null -ne $prop -and $null -ne $prop.GroupBy) {
                $val = "$($prop.GroupBy)".Trim()
                if ($val -eq "") {
                    Set-StatusView -Text "DISABLED (None - Clean View)" -Brush ([System.Windows.Media.Brushes]::LightGreen)
                    return
                } elseif ($val -eq "System.DateModified") {
                    Set-StatusView -Text "ACTIVE (Group by Date Modified)" -Brush ([System.Windows.Media.Brushes]::Cyan)
                    return
                } elseif ($val -eq "System.ItemNameDisplay") {
                    Set-StatusView -Text "ACTIVE (Group by Name A-Z)" -Brush ([System.Windows.Media.Brushes]::Cyan)
                    return
                } elseif ($val -eq "System.ItemTypeText") {
                    Set-StatusView -Text "ACTIVE (Group by File Type)" -Brush ([System.Windows.Media.Brushes]::Cyan)
                    return
                } else {
                    Set-StatusView -Text "CUSTOM ($val)" -Brush ([System.Windows.Media.Brushes]::Cyan)
                    return
                }
            }
        }
    }

    # Fallback to default
    Set-StatusView -Text "DEFAULT (Windows Preset)" -Brush ([System.Windows.Media.Brushes]::Orange)
}

function Clear-Caches {
    Remove-Item -Path $hkcuBags -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $hkcuBagMRU -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $hkcuStreams -Recurse -Force -ErrorAction SilentlyContinue
    $pkgs = "$env:LocalAppData\Packages"
    if (Test-Path $pkgs) {
        Get-ChildItem -Path $pkgs -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Force -ErrorAction SilentlyContinue "$($_.FullName)\SystemAppData\Helium\UserClasses.dat"
        }
    }
}

function Restart-ExplorerProcess {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
        Start-Process explorer.exe
    }
}

function Set-GlobalGroupBy {
    param([string]$GroupValue = "", [string]$ModeLabel = "None")
    Log-Msg "Clearing cached view states..."
    Clear-Caches

    if (-not (Test-Path $hkcuFolderTypes)) {
        New-Item -Path $hkcuFolderTypes -Force | Out-Null
    }
    if (-not (Test-Path $hkcuAppKey)) {
        New-Item -Path $hkcuAppKey -Force | Out-Null
    }

    $types = @(Get-ChildItem -Path $hklmFolderTypes -ErrorAction SilentlyContinue)
    $count = 0
    foreach ($ft in $types) {
        $ftGuid = $ft.PSChildName
        $hklmTopViews = Join-Path $ft.PSPath "TopViews"
        if (Test-Path $hklmTopViews) {
            $tvs = @(Get-ChildItem -Path $hklmTopViews -ErrorAction SilentlyContinue)
            foreach ($tv in $tvs) {
                $tvGuid = $tv.PSChildName
                $dest = "$hkcuFolderTypes\$ftGuid\TopViews\$tvGuid"
                if (-not (Test-Path $dest)) { New-Item -Path $dest -Force | Out-Null }
                
                $props = (Get-ItemProperty -Path $tv.PSPath).psobject.properties
                foreach ($p in $props) {
                    if ($p.Name -notmatch "^(PS|psobject)") {
                        Set-ItemProperty -Path $dest -Name $p.Name -Value $p.Value -Force -ErrorAction SilentlyContinue
                    }
                }
                Set-ItemProperty -Path $dest -Name "GroupBy" -Value $GroupValue -Type String -Force
                Set-ItemProperty -Path $dest -Name "GroupAscending" -Value "TRUE" -Type String -Force
                $count++
            }
        }
    }

    Set-ItemProperty -Path $hkcuAppKey -Name "Mode" -Value $ModeLabel -Force
    Set-ItemProperty -Path $hkcuAppKey -Name "GroupBy" -Value $GroupValue -Force

    Restart-ExplorerProcess
    Update-StatusUI
    if ($GroupValue -eq "") {
        Log-Msg "Disabled GroupBy across $count templates. Explorer restarted!"
    } else {
        Log-Msg "Applied GroupBy='$GroupValue' across $count templates. Explorer restarted!"
    }
}

# Event Handlers
$btnRefreshStatus.Add_Click({
    Update-StatusUI
    Log-Msg "Refreshed current status."
})

$btnDisableGroup.Add_Click({
    Set-GlobalGroupBy -GroupValue "" -ModeLabel "None"
    Log-Msg "Group By disabled permanently across all folders!"
})

$btnRestoreDefault.Add_Click({
    Log-Msg "Restoring Windows default folder view settings..."
    Remove-Item -Path $hkcuFolderTypes -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $hkcuAppKey) { Set-ItemProperty -Path $hkcuAppKey -Name "Mode" -Value "Default" -Force }
    Clear-Caches
    Restart-ExplorerProcess
    Update-StatusUI
    Log-Msg "Windows default folder grouping restored!"
})

$btnGroupByDate.Add_Click({
    Set-GlobalGroupBy -GroupValue "System.DateModified" -ModeLabel "Date"
    Log-Msg "Applied global grouping: Date Modified"
})

$btnGroupByName.Add_Click({
    Set-GlobalGroupBy -GroupValue "System.ItemNameDisplay" -ModeLabel "Name"
    Log-Msg "Applied global grouping: Name (A-Z)"
})

$btnGroupByType.Add_Click({
    Set-GlobalGroupBy -GroupValue "System.ItemTypeText" -ModeLabel "Type"
    Log-Msg "Applied global grouping: File Type"
})

$btnRestartExplorer.Add_Click({
    Log-Msg "Restarting File Explorer..."
    Restart-ExplorerProcess
    Update-StatusUI
    Log-Msg "Explorer restarted."
})

# Auto-update status on window loaded and window activated
$window.Add_Loaded({
    Update-StatusUI
})

$window.Add_Activated({
    Update-StatusUI
})

# Show Dialog
Update-StatusUI
$window.ShowDialog() | Out-Null
