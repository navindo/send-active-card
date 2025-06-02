function Get-WellbeingCalendarMessage {
    param (
        [array]$events
    )

    # Convert to datetime
    $parsedEvents = $events | ForEach-Object {
        [PSCustomObject]@{
            Start = [datetime]$_.start.dateTime
            End   = [datetime]$_.end.dateTime
        }
    } | Sort-Object Start

    # Define blocks
    $morningStart = (Get-Date).Date.AddHours(9)
    $morningEnd   = (Get-Date).Date.AddHours(12)
    $afternoonStart = (Get-Date).Date.AddHours(12)
    $afternoonEnd   = (Get-Date).Date.AddHours(17)
    $lateThreshold  = (Get-Date).Date.AddHours(20)

    # Categorize
    $morningMeetings   = @()
    $afternoonMeetings = @()
    $lateMeetings      = @()

    $totalMeetingMinutes = 0
    $meetingCount = $parsedEvents.Count

    for ($i = 0; $i -lt $parsedEvents.Count; $i++) {
        $e = $parsedEvents[$i]

        # Block totals
        $duration = ($e.End - $e.Start).TotalMinutes
        $totalMeetingMinutes += $duration

        if ($e.Start -ge $morningStart -and $e.End -le $morningEnd) {
            $morningMeetings += $e
        }
        elseif ($e.Start -ge $afternoonStart -and $e.End -le $afternoonEnd) {
            $afternoonMeetings += $e
        }

        if ($e.Start -ge $lateThreshold) {
            $lateMeetings += $e
        }
    }

    $totalMorningMinutes   = ($morningMeetings   | Measure-Object -Property { ($_.End - $_.Start).TotalMinutes } -Sum).Sum
    $totalAfternoonMinutes = ($afternoonMeetings | Measure-Object -Property { ($_.End - $_.Start).TotalMinutes } -Sum).Sum

    # Detect back-to-back
    $hasBackToBack = $false
    for ($i = 1; $i -lt $parsedEvents.Count; $i++) {
        $gap = ($parsedEvents[$i].Start - $parsedEvents[$i - 1].End).TotalMinutes
        if ($gap -lt 15 -and $gap -ge 0) {
            $hasBackToBack = $true
            break
        }
    }

    # Compose based on priority
    if ($totalMeetingMinutes -ge 300) {
        return @"
Good morning, Navin ☀️

Today’s calendar is packed — over 5 hours of meetings lined up.

Make space for your breath. Stretch when you can. Your mind needs margins too.
"@
    }
    elseif ($hasBackToBack) {
        return @"
Good morning, Navin ☀️

Your day’s stitched tight — several meetings are lined up with barely any breathing room.

Be mindful of transitions. A deep breath between calls can go a long way.
"@
    }
    elseif ($meetingCount -ge 4) {
        return @"
Good morning, Navin ☀️

You’ve got a full rhythm today — 4+ meetings spread across the day.

Pace yourself. Breaks aren’t luxuries, they’re fuel.
"@
    }
    elseif ($totalAfternoonMinutes -ge 180 -and $lateMeetings.Count -gt 0) {
        return @"
Good morning, Navin ☀️

Your afternoon is fully booked from 12PM to 5PM, and there's a late call past 8PM.

Try to pause before the evening kicks in — your energy deserves care.
"@
    }
    elseif ($totalAfternoonMinutes -ge 180) {
        return @"
Good morning, Navin ☀️

A deep-focus afternoon ahead — meetings stretch between 12PM and 5PM.

Take a moment before diving in — even a 10-minute reset can lift your clarity.
"@
    }
    elseif ($totalMorningMinutes -ge 90) {
        return @"
Good morning, Navin ☀️

Your morning from 9AM to noon looks focused and full.

Don’t forget a short mid-morning breather — start strong, stay steady.
"@
    }
    elseif ($lateMeetings.Count -gt 0) {
        return @"
Good morning, Navin ☀️

Today’s flow is calm till the evening — but there’s a late session on your calendar.

Stay light through the day and wrap with care tonight.
"@
    }
    elseif ($meetingCount -le 1 -and $totalMeetingMinutes -lt 60) {
        return @"
Good morning, Navin ☀️

It’s a light day on your calendar.

Perfect time to reflect, recalibrate, or just breathe a little easier.
"@
    }
    else {
        return @"
Good morning, Navin ☀️

A few check-ins dot your day, but nothing too heavy.

Keep your pace gentle and stay present — you’re in control today.
"@
    }
}


$response = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} `
  -Uri "$graphUrl/users/$userId/calendarView?startDateTime=$start&endDateTime=$end&$top=50" `
  -Method GET

$message = Get-WellbeingCalendarMessage -events $response.value
Write-Output $message