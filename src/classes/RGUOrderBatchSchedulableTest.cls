/**
 *This class is to cover RGUOrderBatchSchedulable class 
 * @author Gafoor
 * @date 24/05/2016
 */
@isTest
public class RGUOrderBatchSchedulableTest {
 static testMethod void rGUtest() {
        Test.startTest();        
        // Schedular Test
        RGUOrderBatchSchedulable sc = new RGUOrderBatchSchedulable();        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';
        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);                
        Test.stopTest();    
    }
}