/// Description
Class UnitTest.dc.cron.task Extends %UnitTest.TestCase
{

/// Test CronMaker Every 15 minutes
Method TestEvery15Minutes() As %Status
{
    Set sc = $$$OK
    Set cronMakerExpression = "0 0/15 * 1/1 * ? *"
    Do $$$LogMessage("Every 15 minutes: 0 0/15 * 1/1 * ? *")

    Set sc = ##class(dc.cron.task).ProcessCronMakerExpression(cronMakerExpression, .taskProperties)
    Do $$$AssertStatusOK(sc)

    Set expected("TimePeriod") = 0
    Set expected("TimePeriodEvery") = 1
    Set expected("DailyFrequency") = 1
    Set expected("DailyFrequencyTime") = 0
    Set expected("DailyIncrement") = 15
    Set expected("TimePeriodDay") = ""
    Do ..checkExpectedValue(.expected, .taskProperties)

    Return sc
}

Method TestEvery3Hours() As %Status
{
    Set sc = $$$OK
    Set cronMakerExpression = "0 0 0/3 1/1 * ? *"
    Do $$$LogMessage("Every 3 hours: 0 0 0/3 1/1 * ? *")

    Set sc = ##class(dc.cron.task).ProcessCronMakerExpression(cronMakerExpression, .taskProperties)
    Do $$$AssertStatusOK(sc)

    Set expected("TimePeriod") = 0
    Set expected("TimePeriodEvery") = 1
    Set expected("DailyFrequency") = 1
    Set expected("DailyFrequencyTime") = 1
    Set expected("DailyIncrement") = 3
    Set expected("TimePeriodDay") = ""

    Do ..checkExpectedValue(.expected, .taskProperties)
    
    Return sc
}

Method TestEveryDay() As %Status
{
    Set sc = $$$OK
    Set cronMakerExpression = "0 0 14 1/1 * ? *"
    Do $$$LogMessage("Every day at 2:00PM : 0 0 14 1/1 * ? *")

    Set sc = ##class(dc.cron.task).ProcessCronMakerExpression(cronMakerExpression, .taskProperties)
    Do $$$AssertStatusOK(sc)

    Set expected("TimePeriod") = 0
    Set expected("TimePeriodEvery") = 1
    Set expected("DailyFrequency") = 0
    Set expected("DailyStartTime") = 14 * 3600
    
    Set expected("TimePeriodDay") = ""

    Do ..checkExpectedValue(.expected, .taskProperties)
    
    Return sc
}

Method TestEveryMondayAndTuesday() As %Status
{
    Set sc = $$$OK
    Set cronMakerExpression = "0 0 14 ? * MON,TUE *"
    Do $$$LogMessage("Every Monday and Tuesday at 2:00PM : 0 0 14 ? * MON,TUE *")

    Set sc = ##class(dc.cron.task).ProcessCronMakerExpression(cronMakerExpression, .taskProperties)
    Do $$$AssertStatusOK(sc)

    Set expected("TimePeriod") = 1
    Set expected("TimePeriodEvery") = 1
    Set expected("DailyFrequency") = 0
    Set expected("DailyStartTime") = 14 * 3600
    
    Set expected("TimePeriodDay") = "23"

    Do ..checkExpectedValue(.expected, .taskProperties)
    
    Return sc
}

Method TestEveryLastDayOfMonth() As %Status
{
    Set sc = $$$OK
    Set cronMakerExpression = "0 0 14 31 1/1 ? *"
    Do $$$LogMessage("Last day of month at 2:00PM : 0 0 14 31 1/1 ? *")

    Set sc = ##class(dc.cron.task).ProcessCronMakerExpression(cronMakerExpression, .taskProperties)
    Do $$$AssertStatusOK(sc)

    Set expected("TimePeriod") = 2
    Set expected("TimePeriodEvery") = 1
    Set expected("DailyFrequency") = 0
    Set expected("DailyStartTime") = 14 * 3600
    Set expected("TimePeriodDay") = "31"

    Do ..checkExpectedValue(.expected, .taskProperties)
    
    Return sc
}

Method TestEveryLastDayOfOtherMonth() As %Status
{
    Set sc = $$$OK
    Set cronMakerExpression = "0 0 14 31 1/2 ? *"
    Do $$$LogMessage("Last day every 2 months at 2:00PM : 0 0 14 31 1/2 ? *")

    Set sc = ##class(dc.cron.task).ProcessCronMakerExpression(cronMakerExpression, .taskProperties)
    Do $$$AssertStatusOK(sc)

    Set expected("TimePeriod") = 2
    Set expected("TimePeriodEvery") = 2
    Set expected("DailyFrequency") = 0
    Set expected("DailyStartTime") = 14 * 3600
    Set expected("TimePeriodDay") = "31"

    Do ..checkExpectedValue(.expected, .taskProperties)
    
    Return sc
}

Method TestEvery2Month3rdFriday() As %Status
{
    Set sc = $$$OK
    Set cronMakerExpression = "0 0 14 ? 1/2 FRI#3 *"
    Do $$$LogMessage("The third friday every 2 month at 2:00PM every 2 months : 0 0 14 ? 1/2 FRI#3 *")

    Set sc = ##class(dc.cron.task).ProcessCronMakerExpression(cronMakerExpression, .taskProperties)
    Do $$$AssertStatusOK(sc)

    Set expected("TimePeriod") = 3
    Set expected("TimePeriodEvery") = 2
    Set expected("DailyFrequency") = 0
    Set expected("DailyStartTime") = 14 * 3600
    Set expected("TimePeriodDay") = "3^6"

    Do ..checkExpectedValue(.expected, .taskProperties)
    
    Return sc
}

Method checkExpectedValue(ByRef expected As %Binary, ByRef taskProperties As %Binary) As %Status [ Private ]
{
    Set key = ""
    For  {
        Set key = $Order(expected(key),1, expectedValue)
        Quit:key=""
        
        Do $$$AssertEquals(expectedValue, $Get(taskProperties(key)), key _" must be equals "_expectedValue _ "(was " _ $Get(taskProperties(key)) _")")
    }

    Quit $$$OK
}

}
