Class dc.cron.task
{

/// cron expression for schedule
/// * * * * * - run every minute
/// 0 * * * * - run every hour
/// 0 0 * * * - run every day at midnight
ClassMethod Start(cron, runcode, runnow = 1, ByRef tid) As %Status
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

ClassMethod Kill(tid As %Integer) As %Status
{
    
    return ##class(%SYS.Task).%DeleteId(tid)
}

}
