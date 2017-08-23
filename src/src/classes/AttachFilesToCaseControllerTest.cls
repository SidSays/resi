/*
Test Class for AttachFilesToCaseController
@Author: Shalaka Kadwade
@Date: 08-Nov-2016
*/
@isTest
public class AttachFilesToCaseControllerTest {
    
    static testMethod void AttachFilesToCaseControllerTest(){
        
        Id parentId;
    
        Test.starttest();
        
        case newcase = new case(); 
        newcase.Request_Type__c='SFA 2';
        newcase.Ticket_Category__c='Data';
        newcase.Ticket_Category_II__c='Address';
        newcase.Channel__c='Direct Sales';
        newcase.Region__c='Corporate';
        newcase.Description='Test Run';
        newcase.Preferred_Email__c='test_mctesty@cable.comcast.com';
        insert newcase;
        
        id caseid = newcase.id;
        
        ApexPages.StandardController sc = new ApexPages.standardController(newcase);
        PageReference pageRef = Page.AttachFilesToCase;
        
        parentId = pageRef.getParameters().put('CaseId',newcase.id);
        Attachment atch1 = new Attachment();
        String body = 'fileBody1';
        pageRef.getParameters().put('fileBody1',body);
        Test.setCurrentPage(pageRef);
        
        AttachFilesToCaseController  controller = new AttachFilesToCaseController();
        controller.fileName1='Unit Test Attachment1';
        controller.fileBody1=Blob.valueOf('Unit Test Attachment Body1');
        controller.fileName2='Unit Test Attachment2';
        controller.fileBody2=Blob.valueOf('Unit Test Attachment Body2');
        controller.fileName3='Unit Test Attachment3';
        controller.fileBody3=Blob.valueOf('Unit Test Attachment Body3');
        controller.attachFiles();
        
        test.stoptest();    
    
    }
}