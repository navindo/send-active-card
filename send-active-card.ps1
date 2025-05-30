$objectId = "4f7c0e8c-2059-4b54-bb11-62e653d1da8c"

# Raw Adaptive Card JSON (escaped correctly for PowerShell)
$cardJson = @'
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "backgroundImage": {
    "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/White_background.jpg/800px-White_background.jpg",
    "fillMode": "Cover"
  },
  "body": [
    {
      "type": "TextBlock",
      "text": "Time for an Eye Break",
      "weight": "Bolder",
      "size": "Large",
      "wrap": true,
      "horizontalAlignment": "Center",
      "color": "Attention",
      "spacing": "Large"
    },
    {
      "type": "Image",
  "url": "https://media.istockphoto.com/id/1707513300/vector/eye-strain.jpg?s=1024x1024&w=is&k=20&c=wGRw9l9PT2mJ25UndAh_hFLXsqODSWjGAs9huH0FDhQ=",
  "horizontalAlignment": "Center",
  "width": "120px",
  "height": "120px",
  "style": "Default",
  "spacing": "Medium"
    },
    {
  "type": "TextBlock",
  "text": "**Relax your eyes.**\n\nLook at something 20 feet away for **20 seconds** to reduce screen fatigue.",
  "wrap": true,
  "spacing": "Medium",
  "horizontalAlignment": "Center",
  "color": "Default",
  "isSubtle": false,
  "size": "Medium"
}

  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Snooze",
      "style": "default",
      "data": {
        "command": "snooze for 1 hour"
      }
    },
    {
      "type": "Action.OpenUrl",
      "title": "Notification Settings",
      "style": "positive",
      "url": "https://purple-sky-079b5ed00.6.azurestaticapps.net/" 
    }
  ]
}
'@ | ConvertFrom-Json


# Build the full POST body
$body = @{
    ObjectId = $objectId
    MessageCardJson = $cardJson
} | ConvertTo-Json -Depth 10

# Send the request to your bot
Invoke-RestMethod -Method POST `
  -Uri "https://wellbeingbot-dfcreretembra9bm.southeastasia-01.azurewebsites.net/api/notify" `
  -ContentType "application/json" `
  -Body $body
