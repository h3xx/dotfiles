$actual_out = array_map($format_data_f, $records);
$db = $this->getDatabase();
$expected_out = [
$this->assertArrayHasKey($needle, $haystack, $message);
$this->assertArraySubset($subset, $array, $message);
$this->assertClassHasAttribute($attributeName, $className);
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
$this->assertEqualsCanonicalizing($expected, $actual, $message);
$this->assertEqualsIgnoringCase($expected, $actual, $message);
$this->assertEqualsWithDelta($expected, $actual, $delta, $message);
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
$this->assertIsArray($actual, $message);
$this->assertIsBool($actual, $message);
$this->assertIsCallable($actual, $message);
$this->assertIsFloat($actual, $message);
$this->assertIsInt($actual, $message);
$this->assertIsIterable($actual, $message);
$this->assertIsNumeric($actual, $message);
$this->assertIsObject($actual, $message);
$this->assertIsReadable($filename, $message);
$this->assertIsResource($actual, $message);
$this->assertIsScalar($actual, $message);
$this->assertIsString($actual, $message);
$this->assertIsWritable($filename, $message);
$this->assertJsonFileEqualsJsonFile($expectedFile, $actualFile, $message);
$this->assertJsonStringEqualsJsonFile($expectedFile, $actualJson, $message);
$this->assertJsonStringEqualsJsonString($expectedJson, $actualJson, $message);
$this->assertLessThan($expected, $actual, $message);
$this->assertLessThanOrEqual($expected, $actual, $message);
$this->assertNan($variable, $message);
$this->assertNotEmpty($actual, $message);
$this->assertNull($variable, $message);
$this->assertObjectHasAttribute($attributeName, $object, $message);
$this->assertRegExp($pattern, $string, $message);
$this->assertSame($expected, $actual, $message);
$this->assertStringContainsString($needle, $haystack, $message);
$this->assertStringContainsStringIgnoringCase($needle, $haystack, $message);
$this->assertStringEndsWith($suffix, $string, $message);
$this->assertStringEqualsFile($expectedFile, $actualString, $message);
$this->assertStringMatchesFormat($format, $string, $message);
$this->assertStringMatchesFormatFile($formatFile, $string, $message);
$this->assertStringStartsWith($prefix, $string, $message);
$this->assertThat($value, $this->logicalNot($this->equalTo($otherValue)), $message);
$this->assertTrue($condition, $message);
$this->assertXmlFileEqualsXmlFile($expectedFile, $actualFile, $message);
$this->assertXmlStringEqualsXmlFile($expectedFile, $actualXml, $message);
$this->assertXmlStringEqualsXmlString($expectedXml, $actualXml, $message);
$this->equalTo($value)
$this->markTestIncomplete($message);
$this->returnCallback($func)
$this->returnValue($value)
$this->throwException($exception)
$yaml = __DIR__.'/'.static::DATADIR.'/dataset.yaml';
* @after
* @afterClass
* @author
* @backupGlobals
* @backupStaticAttributes
* @before
* @beforeClass
* @codeCoverageIgnore
* @codeCoverageIgnoreEnd
* @codeCoverageIgnoreStart
* @covers
* @coversDefaultClass
* @coversNothing
* @dataProvider
* @depends
* @group
* @large
* @medium
* @param
* @preserveGlobalState
* @requires
* @return
* @runInSeparateProcess
* @runTestsInSeparateProcesses
* @small
* @test
* @testdox
* @throws Exception
* @ticket
* @uses
PHPUnit_Extensions_Database_DataSet_IDataSet
class Test extends EcDatabaseTestCase {
class Test extends PHPUnit_Framework_TestCase {
const DATADIR = 
expectException
expectExceptionCode
expectExceptionMessage
expectExceptionMessageRegExp
foreach ($test_cases as $test_id => $buff) {
if ($exception !== $expected_out[$test_id]) {
public function getDataSet() {
return new PHPUnit_Extensions_Database_DataSet_YamlDataSet($yaml);
use TestOutputCapture;
