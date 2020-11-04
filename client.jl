#!/usr/bin/env julia
import HTTP
import JSON
using DelimitedFiles

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
                return JSON.parse(String(response.body))
        else
                error(response.status)
        end
        # return response.body
end



title = "Title"
message = "This is the message body."
message = replace(message, "\n" => "\n\r")
buttontext = "Click me!"
buttonuri = "https://duck.com"

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

