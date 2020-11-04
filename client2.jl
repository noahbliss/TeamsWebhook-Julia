#!/usr/bin/env julia
import HTTP
import JSON
using DelimitedFiles
using Dates

#settingsfile = "spike.conf"
backupsettingsfile = "$(homedir())/.config/o365webhook-julia/spike.conf"
@isdefined(settingsfile) || isfile(backupsettingsfile) && (settingsfile = backupsettingsfile)
isfile(settingsfile) || println("Settings file is missing.") && exit(1)

importedvars = readdlm(settingsfile, '=', String; skipblanks=true)
a2var(key, a) = (c=1; for i in a[:, 1]; i == key && return a[c, 2]; c+=1; end || error("$key not found"))

uri = a2var("uri", importedvars)

function webreq(uri, payload)
        #uri = "$uri/api/$query"
        headers = ["Content-Type" => "application/json" ]
        payload = JSON.json(payload)
        response = HTTP.request("POST", uri, headers, payload; require_ssl_verification = true)
        #return String(response.body)
        if response.status == 200
                #return JSON.parse(String(response.body)) #Returns 1 on success.
                return response.status #Returns 200 on success.
        else
                error(response.status)
        end
        # return response.body
end

function send(title, message, buttontext, buttonuri)
        message = replace(message, "\n" => "\n\r")
        payload = Dict(
                "@context" => "https://schema.org/extensions",
                "@type" => "MessageCard",
                "themeColor" => "383838",
                "title" => title,
                "text" => message,
                "potentialAction" => Any[Dict(
                        "@type" => "OpenUri",
                        "name" => buttontext,
                        "targets" => Any[Dict(
                                "os" => "default",
                                "uri" => buttonuri
                                )]
                        )]
        )
        response = webreq(uri, payload)
end



# Here we build our message.
dt = now(UTC)
dtlocal = now()
prettydt = "$(hour(dt)):$(minute(dt)):$(second(dt)) $(month(dt))/$(day(dt))/$(year(dt))" #20:18:30 11/4/2020
prettydtlocal = "$(hour(dtlocal)):$(minute(dtlocal)):$(second(dtlocal)) - $(month(dtlocal))/$(day(dtlocal))/$(year(dtlocal))" #16:40:42 - 11/4/2020

incidenttype = "BRUTEFORCE"
targetasset = "TARGETASSET"
compromise = "NOT DETECTED" #DETECTED
playbookname = "BLOCK\\_SOURCE\\_IP"
playbookresult = "COMPLETED"
detectionsource = "WinEventLog Source"

# These Variables will actually be used in the function call.
title = "This is a TEST Security Incident Notification"
message = "Type: **$incidenttype**
Target: **$targetasset**
Detection Time UTC: **$prettydt** -- Local: **$prettydtlocal**
Compromise: **$compromise**
Auto Triage Action: **$playbookname**
Auto Triage Result: **$playbookresult**
Detection Source: **$detectionsource**"

buttontext = "Additional Details"
buttonuri = "https://hackertyper.net/"

# Send the message.
result = send(title, message, buttontext, buttonuri)
