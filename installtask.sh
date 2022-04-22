#! /bin/sh
execPowerShell () {
    Powershell.exe -Command "$@" |tr -d '\r'
}

userprofile=`powershell.exe 'echo $env:USERPROFILE'|sed -e "s/[\r\n]\+//g"`
taskpath=$(wslpath $userprofile)/AppData/Local/Tasks
vbs=ipv6.vbs

if [ ! -d $taskpath ];then
   mkdir -p $taskpath
fi

cat <<- EOF > $taskpath/$vbs
    Set ws = CreateObject("WScript.Shell")
    ws.run "wsl -d ipv6 enable", 0, true
EOF

script=$(wslpath -w $taskpath/$vbs)
cat <<EOF | iconv -tutf-16 > $taskpath/.$vbs.xml
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <LogonTrigger>
      <Repetition>
        <Interval>PT1H</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <Enabled>true</Enabled>
    </LogonTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and EventID=1]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>wscript.exe</Command>
      <Arguments>$script</Arguments>
    </Exec>
  </Actions>
</Task>
EOF

xml=$(wslpath -w $taskpath/.$vbs.xml)
p="schtasks.exe /CREATE /TN '\WSL\IPv6 Enabler' /XML $xml"
powershell.exe start-process powershell.exe -wait -WindowStyle Hidden -Verb runas \"$p\"
rm $taskpath/.$vbs.xml
