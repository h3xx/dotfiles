" vi: sw=4 sts=4 ts=4 et

insert
<?php

/**
 * @covers SOMECLASS
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/
append
 */
#class CLASS extends EmaxDatabaseTestCase {
.
s/CLASS/\=expand("%:t:r")/
append
#class CLASS extends EcDatabaseTestCase {
.
s/CLASS/\=expand("%:t:r")/
append
class CLASS extends PHPUnit_Framework_TestCase {
.
s/CLASS/\=expand("%:t:r")/

append

    #const DATADIR = 'CLASSData';
.
s/CLASS/\=expand("%:t:r")/
append

    /**
     * @return void
     */
    public function test SOMEMETHOD() {
        #$db = $this->getDatabase();
        #$config = new ConfigUtilTestWrapper;

        $mock = $this->getMockBuilder(SOMECLASS::class)
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/g
append
            ->setMethods([
                'dieString',
            ])
            ->disableOriginalConstructor()
            ->getMock();

        $reflector = new ReflectionClass($mock);

        $meth = $reflector->getMethod('SOMEMETHOD');
        $meth->setAccessible(true);
        $actual = $meth->invokeArgs($mock, [$MYARG]);

        $expected = [
        ];

        $message = "U wot m8?";
        $this->assertEquals($expected, $actual, $message);
    }

    private function setupContext(ConfigUtil $config = null, PDO $db = null) {
        $mock_context = $this->getMockBuilder(DefaultGlobalContext::class)
            ->setMethods([
                'getConfigObj',
                'getDatabase',
            ])
            ->disableOriginalConstructor()
            ->getMock();
        if (isset($config)) {
            $mock_context->expects($this->any())
                ->method('getConfigObj')
                ->will($this->returnValue($config));
        }
        if (isset($db)) {
            $mock_context->expects($this->any())
                ->method('getDatabase')
                ->will($this->returnValue($db));
        }
        DefaultGlobalContextProvider::setGlobalContext($mock_context);
    } // end setupContext()

}
.
13
