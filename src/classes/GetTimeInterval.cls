@RestResource(urlMapping='/GetTimeInterval/*')

global with sharing class GetTimeInterval{

    @HttpGet
    global static Integer getTime(){
        Integer timeInterval = 10;
        return timeInterval;
    }
}