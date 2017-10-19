" vi: sw=4 sts=4 ts=4 et

insert
<?php

class CLASS extends EcDatabaseTestCase {
.
s/CLASS/\=expand("%:t:r")/
append
#class CLASS extends PHPUnit_Framework_TestCase {
.
s/CLASS/\=expand("%:t:r")/

append

    const DATADIR = 'CLASSData';
.
s/CLASS/\=expand("%:t:r")/
append

    /**
     * @covers SOMECLASS::SOMEMETHOD
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/
append
     */
    public function test SOMEMETHOD() {
        $db = $this->getDatabase();

        $config = new ConfigUtilTestWrapper;

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

        $prop = $reflector->getProperty('database');
        $prop->setAccessible(true);
        $prop->setValue($mock, $db);

        $prop = $reflector->getProperty('config');
        $prop->setAccessible(true);
        $prop->setValue($mock, $config);

        $meth = $reflector->getMethod('SOMEMETHOD');
        $meth->setAccessible(true);
        $actual = $meth->invokeArgs($mock, [$MYARG]);

        $expected = [
        ];

        $message = "U wot m8?";
        $this->assertEquals($expected, $actual, $message);
    }

    /**
     * @covers SOMECLASS::getSmartyVersion
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/
append
     */
    public function testgetSmartyVersion() {

        $mock = $this->getMockBuilder('SOMECLASS')
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/g
append
            ->setMethods([
                'dieString',
            ])
            ->disableOriginalConstructor()
            ->getMock();

        $reflector = new ReflectionClass($mock);

        $expected = 3;

        $meth = $reflector->getMethod('getSmartyVersion');
        $meth->setAccessible(true);
        $actual = $meth->invoke($mock);

        $message = "Bad Smarty version given by page";
        $this->assertEquals($expected, $actual, $message);
    }

}

class SOMECLASSWrapper extends SOMECLASS {
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/g
append
    use TestOutputCapture;
}
.
