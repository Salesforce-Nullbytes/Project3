@isTest
public class TestSubmitControllerTest {

  static final String testClassBody = '@isTest private class TestT1{' +
    '    public static testmethod void test2(){' +
    '      String s = C1.method1();' +
    '      System.assert(s=="HELLO");' +
    '    }' +
    '}';

  static final String classBody = 'public class C1{' +
    '    public static String s = + HELLO;' +
    '    public static String method1(){' +
    '      return(s);' +
    '    }' +
    '}';

  static final String classBadBody = 'public class C1{' +
    '    public static text s = + HELLO' +
    '    public static String method1(){' +
    '      return(s);' +
    '    }' +
    '}';
  
  @isTest
  public static void TP_compileClass(){

    Test.setMock(WebServiceMock.class, new SOAPMock());
    try {
      String output = TestSubmitController.compileClass(classBody,false);

      System.debug('output' + output);

      System.assertNotEquals('Mock Response', output, 'TP works');
    } catch (Exception ex) {
      throw new AuraHandledException(ex.getMessage());
    }
      
  }

  @isTest
  public static void TN_compileClass(){

    try {
      Test.setMock(WebServiceMock.class, new SOAPMock());

      String result = TestSubmitController.compileClass( classBadBody,false);

      System.debug('result ' + result);

      System.assertNotEquals('null', result,'TN works');

    } catch (Exception ec) {
      throw new AuraHandledException(ec.getMessage());
    }
    
  }

  @isTest
  public static void TP_submitResponse(){

    try {
      Test.setMock(WebServiceMock.class, new SOAPMock());

      String result = TestSubmitController.submitResponse('response', classBody, false);

      System.debug('result ' + result);

      System.assertNotEquals('null', result,'TN works');

    } catch (Exception ec) {
      throw new AuraHandledException(ec.getMessage());
    }
    
  }

  @isTest
  public static void TN_submitResponse(){

    try {
      Test.setMock(WebServiceMock.class, new SOAPMock());

      String result = TestSubmitController.submitResponse('response', classBadBody, false);

      System.debug('result ' + result);

      System.assertNotEquals('null', result,'TN works');

    } catch (Exception ec) {
      throw new AuraHandledException(ec.getMessage());
    }
    
  }

  @isTest
  public static void TN_fetchUserSessionId(){

    try {
      Test.startTest();

      String result = TestSubmitController.fetchUserSessionId();

      System.debug('result ' + result);

      System.assertNotEquals('null', result,'TN works');

      Test.stopTest();

    } catch (Exception ec) {
      throw new AuraHandledException(ec.getMessage());
    }
    
  }

  @isTest
  public static void Test_WSDL(){
    soapSforceCom200608Apex.TestsNode testnode = new soapSforceCom200608Apex.TestsNode();
    soapSforceCom200608Apex.CallOptions_element elem = new soapSforceCom200608Apex.CallOptions_element();
    soapSforceCom200608Apex.DebuggingHeader_element Debug = new soapSforceCom200608Apex.DebuggingHeader_element();
    soapSforceCom200608Apex.PackageVersion pack = new soapSforceCom200608Apex.PackageVersion();
    soapSforceCom200608Apex.WsdlToApexResult WSDL = new soapSforceCom200608Apex.WsdlToApexResult();
    soapSforceCom200608Apex.wsdlToApex_element WSDL_elem = new soapSforceCom200608Apex.wsdlToApex_element();
    soapSforceCom200608Apex.AllowFieldTruncationHeader_element allow = new soapSforceCom200608Apex.AllowFieldTruncationHeader_element();
    soapSforceCom200608Apex.NamespacePackagePair name = new soapSforceCom200608Apex.NamespacePackagePair();
    soapSforceCom200608Apex.wsdlToApexResponse_element WSDL_response = new soapSforceCom200608Apex.wsdlToApexResponse_element();
    soapSforceCom200608Apex.LogInfo log = new soapSforceCom200608Apex.LogInfo();
    soapSforceCom200608Apex.DebuggingInfo_element debug_info = new soapSforceCom200608Apex.DebuggingInfo_element();
    soapSforceCom200608Apex.compileClassesResponse_element CCR_elem = new soapSforceCom200608Apex.compileClassesResponse_element();
    soapSforceCom200608Apex.compileTriggers_element trig_elem = new soapSforceCom200608Apex.compileTriggers_element();
    soapSforceCom200608Apex.compileClasses_element classes_elem = new soapSforceCom200608Apex.compileClasses_element();
    soapSforceCom200608Apex.WsdlToApexInfo WSDL_info = new soapSforceCom200608Apex.WsdlToApexInfo();
    soapSforceCom200608Apex.ExecuteAnonymousResult exec = new soapSforceCom200608Apex.ExecuteAnonymousResult();
    soapSforceCom200608Apex.PackageVersionHeader_element header = new soapSforceCom200608Apex.PackageVersionHeader_element();
    soapSforceCom200608Apex.DisableFeedTrackingHeader_element feed = new soapSforceCom200608Apex.DisableFeedTrackingHeader_element();
    soapSforceCom200608Apex.runTestsResponse_element run = new soapSforceCom200608Apex.runTestsResponse_element();
  }
}
