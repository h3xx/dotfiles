class Test extends EcDatabaseTestCase {
class Test extends PHPUnit_Framework_TestCase {
const DATADIR = 
$actual_out = array_map($format_data_f, $records);
foreach ($test_cases as $test_id => $buff) {
if ($exception !== $expected_out[$test_id]) {
$db = $this->getDatabase();
$expected_out = [
use TestOutputCapture;
// wrap expose some methods
public function getDataSet() {
$yaml = __DIR__.'/'.static::DATADIR.'/dataset.yaml';
return new PHPUnit_Extensions_Database_DataSet_YamlDataSet($yaml);
$this->assertEquals($expected_out, $actual_out, $message);
