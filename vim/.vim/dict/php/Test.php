class Test extends EcDatabaseTestCase {
class Test extends PHPUnit_Framework_TestCase {
const DATADIR = 
$actual_out = array_map($format_data_f, $records);
foreach ($test_cases as $test_id => $buff) {
if ($exception !== $expected_out[$test_id]) {
$db = $this->getDatabase();
$expected_out = [
use TestOutputCapture;
public function getDataSet() {
$yaml = __DIR__.'/'.static::DATADIR.'/dataset.yaml';
return new PHPUnit_Extensions_Database_DataSet_YamlDataSet($yaml);
* @return
* @param
* @throws Exception
* @author
* @after
* @afterClass
* @backupGlobals
* @backupStaticAttributes
* @before
* @beforeClass
* @codeCoverageIgnore
* @codeCoverageIgnoreStart
* @codeCoverageIgnoreEnd
* @covers
* @coversDefaultClass
* @coversNothing
* @dataProvider
* @depends
* @expectedException
* @expectedExceptionCode
* @expectedExceptionMessage
* @expectedExceptionMessageRegExp
* @group
* @large
* @medium
* @preserveGlobalState
* @requires
* @runTestsInSeparateProcesses
* @runInSeparateProcess
* @small
* @test
* @testdox
* @ticket
* @uses
$this->assertArrayHasKey($needle, $haystack, $message);
$this->assertClassHasAttribute($attributeName, $className);
$this->assertArraySubset($subset, $array, $message);
$this->assertClassHasStaticAttribute($attributeName, $className, $message);
$this->assertContains($needle, $haystack, $message, $ignoreCase);
$this->assertContainsOnly($type, $haystack, $isNativeType, $message);
$this->assertContainsOnlyInstancesOf($className, $haystack, $message);
$this->assertCount($expectedCount, $haystack, $message);
$this->assertDirectoryExists($directory, $message);
$this->assertDirectoryIsReadable($directory, $message);
$this->assertDirectoryIsWritable($directory, $message);
$this->assertEmpty($actual, $message);
$this->assertEqualXMLStructure($expectedElement, $actualElement);
$this->assertEquals($expected, $actual, $message);
$this->assertFalse($condition, $message);
$this->assertFileEquals($expected, $actual, $message);
$this->assertFileExists($filename, $message);
$this->assertFileIsReadable($filename, $message);
$this->assertFileIsWritable($filename, $message);
$this->assertGreaterThan($expected, $actual, $message);
$this->assertGreaterThanOrEqual($expected, $actual, $message);
$this->assertInfinite($variable, $message);
$this->assertInstanceOf($expected, $actual, $message);
$this->assertInternalType($expected, $actual, $message);
$this->assertIsReadable($filename, $message);
$this->assertIsWritable($filename, $message);
$this->assertJsonFileEqualsJsonFile($expectedFile, $actualFile, $message);
$this->assertJsonStringEqualsJsonFile($expectedFile, $actualJson, $message);
$this->assertJsonStringEqualsJsonString($expectedJson, $actualJson, $message);
$this->assertLessThan($expected, $actual, $message);
$this->assertLessThanOrEqual($expected, $actual, $message);
$this->assertNan($variable, $message);
$this->assertNull($variable, $message);
$this->assertObjectHasAttribute($attributeName, $object, $message);
$this->assertRegExp($pattern, $string, $message);
$this->assertStringMatchesFormat($format, $string, $message);
$this->assertStringMatchesFormatFile($formatFile, $string, $message);
$this->assertSame($expected, $actual, $message);
$this->assertStringEndsWith($suffix, $string, $message);
$this->assertStringEqualsFile($expectedFile, $actualString, $message);
$this->assertStringStartsWith($prefix, $string, $message);
$this->assertThat($value, $this->logicalNot($this->equalTo($otherValue)), $message);
$this->assertTrue($condition, $message);
$this->assertXmlFileEqualsXmlFile($expectedFile, $actualFile, $message);
$this->assertXmlStringEqualsXmlFile($expectedFile, $actualXml, $message);
$this->assertXmlStringEqualsXmlString($expectedXml, $actualXml, $message);
$this->markTestIncomplete($message);
$this->throwException($exception)
$this->equalTo($value)
$this->returnValue($value)
