<# Notes:

Authors: Jason Helmick and Melissa (Missy) Janusko

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko.
Currently on her public DSC hub located here:
https://github.com/majst32/DSC_public.git

Goal - Create a Domain Controller, Populute with OU's Groups and Users.
       One Server joined to the new domain
       One Windows 10 CLient joined to the new domain

       

Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#> 

@{
    AllNodes = @(
        @{
            NodeName = '*'
            
            # Common networking
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.3.1'
            SubnetMask = 24
            AddressFamily = 'IPv4'
            DnsServerAddress = '192.168.3.10'
                       
            # Domain and Domain Controller information
            DomainName = "Company.Pri"
            DomainDN = "DC=Company,DC=Pri"
            DCDatabasePath = "C:\NTDS"
            DCLogPath = "C:\NTDS"
            SysvolPath = "C:\Sysvol"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true 
                        
            # DHCP Server Data
            DHCPName = 'LabNet'
            DHCPIPStartRange = '192.168.3.200'
            DHCPIPEndRange = '192.168.3.250'
            DHCPSubnetMask = '255.255.255.0'
            DHCPState = 'Active'
            DHCPAddressFamily = 'IPv4'
            DHCPLeaseDuration = '00:08:00'
            DHCPScopeID = '192.168.3.0'
            DHCPDnsServerIPAddress = '192.168.3.10'
            DHCPRouter = '192.168.3.1'

            # Lability default node settings
            Lability_SwitchName = 'LabNet'
            Lability_ProcessorCount = 1
            Lability_StartupMemory = 1GB
            SecureBoot = $false
            Lability_Media = '2016_x64_Standard_Core_EN_Eval' # Can be Core,Win10,2012R2,nano
                                                       # 2016_x64_Standard_EN_Eval
                                                       # 2016_x64_Standard_Core_EN_Eval
                                                       # 2016_x64_Datacenter_EN_Eval
                                                       # 2016_x64_Datacenter_Core_EN_Eval
                                                       # 2016_x64_Standard_Nano_EN_Eval
                                                       # 2016_x64_Datacenter_Nano_EN_Eval
                                                       # 2012R2_x64_Standard_EN_Eval
                                                       # 2012R2_x64_Standard_EN_V5_Eval
                                                       # 2012R2_x64_Standard_Core_EN_Eval
                                                       # 2012R2_x64_Standard_Core_EN_V5_Eval
                                                       # 2012R2_x64_Datacenter_EN_V5_Eval
                                                       # WIN10_x64_Enterprise_EN_Eval
        }
        @{
            NodeName = 'DC1'
            IPAddress = '192.168.3.10'
            Role = 'DC'   # multiple roles @('DC', 'DHCP')
            Lability_BootOrder = 10
            Lability_BootDelay = 60 # Number of seconds to delay before others
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }

        @{
            NodeName = 'S1'
            IPAddress = '192.168.3.50'
            Role = 'DomainJoin' # example of multiple roles @('DomainJoin', 'Web')
            Lability_BootOrder = 20
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }

        @{
            NodeName = 'S2'
            IPAddress = '192.168.3.51'
            Role = 'DomainJoin' # example of multiple roles @('DomainJoin', 'Web')
            Lability_BootOrder = 20
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }

       @{
            NodeName = 'N1'
            IPAddress = '192.168.3.60'
            #Role = 'Nano'
            Lability_BootOrder = 20
            Lability_Media = '2016_x64_Standard_Nano_DSC_EN_Eval'
            Lability_ProcessorCount = 1
            Lability_StartupMemory = 1GB
        }

        @{
            NodeName = 'Cli1'
            IPAddress = '192.168.3.100'
            Role = @('domainJoin', 'RSAT')
            Lability_ProcessorCount = 1
            Lability_StartupMemory = 2GB
            Lability_Media = 'WIN10_x64_Enterprise_EN_Eval'
            Lability_BootOrder = 20
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
            Lability_Resource = @('Win10RSAT');
        }

        
    );
    NonNodeData = @{
        Lability = @{
            # EnvironmentPrefix = 'PS-GUI-' # this will prefix the VM names                                    
            Media = (
                @{
                    ## This media is a replica of the default '2016_x64_Standard_Nano_EN_Eval' media
                    ## with the additional 'Microsoft-NanoServer-DSC-Package' package added.
                    Id = '2016_x64_Standard_Nano_DSC_EN_Eval';
                    Filename = '2016_x64_EN_Eval.iso';
                    Description = 'Windows Server 2016 Standard Nano 64bit English Evaluation';
                    Architecture = 'x64';
                    ImageName = 'Windows Server 2016 SERVERSTANDARDNANO';
                    MediaType = 'ISO';
                    OperatingSystem = 'Windows';
                    Uri = 'http://download.microsoft.com/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO';
                    Checksum = '18A4F00A675B0338F3C7C93C4F131BEB';
                    CustomData = @{
                        SetupComplete = 'CoreCLR';
                        PackagePath = '\NanoServer\Packages';
                        PackageLocale = 'en-US';
                        WimPath = '\NanoServer\NanoServer.wim';
                        Package = @(
                            'Microsoft-NanoServer-Guest-Package',
                            'Microsoft-NanoServer-DSC-Package'
                        )
                    }
                }
            ) # Custom media additions that are different than the supplied defaults (media.json)
            Network = @( # Virtual switch in Hyper-V
                @{ Name = 'LabNet'; Type = 'Internal'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true;}
            );
            DSCResource = @(
                ## Download published version from the PowerShell Gallery or Github
                @{ Name = 'xActiveDirectory'; RequiredVersion="2.13.0.0"; Provider = 'PSGallery'; },
                @{ Name = 'xComputerManagement'; RequiredVersion = '1.8.0.0'; Provider = 'PSGallery'; },
                @{ Name = 'xNetworking'; RequiredVersion = '2.12.0.0'; Provider = 'PSGallery'; },
                @{ Name = 'xDhcpServer'; RequiredVersion = '1.5.0.0'; Provider = 'PSGallery';  },
                @{ Name = 'xWindowsUpdate' ; RequiredVersion = '2.5.0.0'; Provider = 'PSGallery';},
                @{ Name = 'xPSDesiredStateConfiguration'; MinimumVersion = '4.0.0.0'; },
                @{ Name = 'xPendingReboot'; MinimumVersion = '0.3.0.0'; }


            );
            Resource = @(
                @{
                    
                    Id = 'Win10RSAT'
                    Filename = 'WindowsTH-RSAT_WS2016-x64.msu'
                    Uri = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-RSAT_WS2016-x64.msu'
                    Expand = $false                    
                    #DestinationPath = '\software' # Default is resources folder
                }
            );

        };
    };
};