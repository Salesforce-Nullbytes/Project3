@isTest
public class TestSubmitControllerTest {

    static final String testClassBody = '@isTest private class TestT1{' +
      '    public static testmethod void test2(){' +
      '      String s = C1.method1();' +
      '      System.assert(s=="HELLO");' +
      '    }' +
      '}';

    static final String classBody = 'public class C1{' +
      '    public static String s ="HELLO";' +
      '    public static String method1(){' +
      '      return(s);' +
      '    }' +
      '}';

    static final String classBadBody = 'public class C1{' +
      '    public static text s ="HELLO";' +
      '    public static String method1(){' +
      '      return(s);' +
      '    }' +
      '}';
    
    @isTest
    public static void TP_compileClass(){

        Test.startTest();
        
        //soapSforceCom200608Apex.CompileClassResult result = TestSubmitController.compileClass(classBody)[0];

        Test.stopTest();

        //System.assertEquals(true, result.success);

        
    }

    @isTest
    public static void TN_compileClass(){
        //soapSforceCom200608Apex.CompileClassResult result = TestSubmitController.compileClass(classBadBody)[0];

        //System.assertEquals(false, result.success);
    }

}
