Class dc.cron.task
{

/// name - name of the task
/// cron expression for schedule
/// runcode - a string with ObjectScript you want to be executed - it will be xecuted
/// tid - the taskid to be returned. You need it e.g. to suspend/resume or kill the task

ClassMethod Start(name, cron, runcode, runnow = 1, ByRef tid) As %Status
{
    set sc = $$$OK
    set sc = ..StartByCronMakerExpression($g(name,"iris-cron-task"),cron,runcode,$g(runnow,1),.tid )
    return sc
}

/// * * * * * - run every minute
/// 0 * * * * - run every hour
/// 0 0 * * * - run every day at midnight

ClassMethod StartOld(cron, runcode, runnow = 1, ByRef tid) As %Status
{
        set sc = $$$OK
        Set task=##class(%SYS.Task).%New()
        Set task.Name = "Update data"
        Set task.NameSpace=$Namespace
        Set task.TimePeriod=0 // Daily
        Set task.TimePeriodEvery=1 // Every 1 day
        Set task.DailyStartTime = 0 // Start at 00:00:00
        Set task.DailyEndTime = 86399 // End at 23:59:59
        Set task.DailyFrequency=1 // Run Several times in a day
        Set task.StartDate = $p($H,",",1) // Start today
        
        if $Piece(cron," ",1)="*" {
            Set task.DailyFrequencyTime=0  // Run every x minutes
            Set task.DailyIncrement=1 // # of minutes between runs
            }
        if $Piece(cron," ",1)="0" {
            Set task.DailyFrequencyTime=0  // Run every x minutes
            Set task.DailyIncrement=60 // # of minutes between runs
            }
        if $Piece(cron," ",2)'="*" {
            Set task.DailyIncrement=""
            Set task.DailyFrequency=0  // Run every x minutes
            Set task.DailyStartTime = 3600*$Piece(cron," ",2) // # of minutes between runs
            if task.DailyStartTime<$P($H,",",2) {
                Set task.StartDate = task.StartDate+1 // start tomorrow
            }
            }

        
        Set taskdef = ##class(%SYS.Task.RunLegacyTask).%New()
        Set task.TaskClass=$classname(taskdef)
        set taskdef.ExecuteCode=runcode
        Do task.AssignSettings(taskdef)
        Set sc = task.%Save()
        Return:$$$ISERR(sc) sc
        if runnow set sc=##class(%SYS.Task).RunNow(task.%Id())
        set tid=task.%Id()
        return sc
}

/// Cron expression maker : http://www.cronmaker.com
/// 0 0/15 * 1/1 * ? * - every 15 minutes
/// 0 0 0/3 1/1 * ? * - every 3 hours
/// 0 0 14 1/1 * ? * - every day at 2:00PM
/// 0 0 14 ? * MON,TUE * - every Monday and Tuesday at 2:00PM
/// 0 0 14 31 1/1 ? * - every last day of month at 2:00PM
/// 0 0 14 31 1/2 ? * - every Last day of every 2 months at 2:00PM
/// 0 0 14 ? 1/2 FRI#3 * - every third friday at 2:00PM every 2 months
ClassMethod StartByCronMakerExpression(name As %String, cronMakerExpression As %String, runcode As %String, runnow = 1, ByRef tid) As %Status
{
    Set sc = $$$OK
    Set task=##class(%SYS.Task).%New()
    Set task.Name = name
    Set task.NameSpace=$Namespace

    Do ..ProcessCronMakerExpression(cronMakerExpression,.properties)

    Set key = ""
    For  {
        Set key = $Order(properties(key),1,keyValue)
        Quit:key=""
        Set $PROPERTY(task,key) = keyValue
    }

    Set taskdef = ##class(%SYS.Task.RunLegacyTask).%New()
    Set task.TaskClass=$classname(taskdef)
    set taskdef.ExecuteCode=runcode
    Do task.AssignSettings(taskdef)
    Set sc = task.%Save()
    Return:$$$ISERR(sc) sc
    if runnow set sc=##class(%SYS.Task).RunNow(task.%Id())
    set tid=task.%Id()
    return sc
}

/// Cron Maker syntax support
/// http://www.cronmaker.com
ClassMethod ProcessCronMakerExpression(cronMakerExpression As %String, ByRef taskProperties As %Binary) As %Status
{
    Set min = $Piece(cronMakerExpression," ",2), 
        hours =$Piece(cronMakerExpression," ",3), 
        dom = $Piece(cronMakerExpression," ",4), 
        month = $Piece(cronMakerExpression," ",5), 
        dow = $Piece(cronMakerExpression," ",6)

    Set taskProperties("TimePeriod")=0 // Daily
    Set taskProperties("TimePeriodEvery")=1 // Every 1 day
    Set taskProperties("DailyStartTime") = 0 // Start at 00:00:00
    Set taskProperties("DailyEndTime") = 86399 // End at 23:59:59
    Set taskProperties("DailyFrequency")=0 ;1 // Run Several times in a day
    Set taskProperties("StartDate") = $p($H,",",1) // Start today

    Set lstD=$Lb("SUN","MON","TUE","WED","THU","FRI","SUN")
    

    If min '= "*" {
        Set everyXMin = $Piece(min,"/",2)
        If everyXMin '= "" {
            Set taskProperties("DailyFrequencyTime") = 0         ; Run every x minutes.
            Set taskProperties("DailyIncrement") = everyXMin     ; # of minutes between runs
            Set taskProperties("DailyFrequency")=1
        }
    }

    If hours '= "*" {
        Set everyXHours = $Piece(hours,"/",2)
        If everyXHours '= "" {
            Set taskProperties("DailyFrequencyTime") = 1           ; Run every x hours.
            Set taskProperties("DailyIncrement") = everyXHours     ; # of hours between runs
            Set taskProperties("DailyFrequency")=1
        } 

        Set firstHour = $Piece($Piece(hours,"-",1),"/",1)
        Set lastHour = $Piece($Piece(hours,"-",2),"/",1)

        If lastHour '= "" {
            Set taskProperties("DailyStartTime") = firstHour * 3600 + ( +min * 60)    ; first run at ...
            Set taskProperties("DailyEndTime") = lastHour * 3600 + ( +min * 60)       ; last run at ...

            if taskProperties("DailyStartTime")<$P($H,",",2) {
                Set taskProperties("StartDate") = taskProperties("StartDate")+1 // start tomorrow
            }

        } Else {
            Set taskProperties("DailyStartTime") = firstHour * 3600 + ( +min * 60)    ; Run once at ...

            if taskProperties("DailyStartTime")<$P($H,",",2) {
                Set taskProperties("StartDate") = taskProperties("StartDate")+1 // start tomorrow
            }
        }

    }

    If month = "*" {
        
        If dom = "?" { 
            ; Run every week
            Set periodDay = "", lstDow = $LISTFROMSTRING(dow,","), ptr=0
            While $LISTNEXT(lstDow,ptr,v) {
                Set periodDay = periodDay_$LISTFIND(lstD,v)
            }
        
            Set taskProperties("TimePeriod") = 1
            Set taskProperties("TimePeriodDay") = periodDay
        }

    } Else {

        Set everyXMonths = $Piece(month,"/",2)

        If everyXMonths '= "" {
            Set taskProperties("TimePeriodEvery") = everyXMonths ; Run every x months
            Set taskProperties("TimePeriod") = 3
        }

        If dow = "?" {
            Set taskProperties("TimePeriod") = 2
            Set taskProperties("TimePeriodDay") = dom
        }

        If dow [ "#" {
            Set taskProperties("TimePeriod") = 3
            Set taskProperties("TimePeriodDay") = $Piece(dow,"#",2)_"^"_$LISTFIND(lstD,$Piece(dow,"#",1))
        }
    }

    Quit $$$OK
}

ClassMethod Kill(tid As %Integer) As %Status
{
    
    return ##class(%SYS.Task).%DeleteId(tid)
}

}
