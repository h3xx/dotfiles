" vi: sw=4 sts=4 ts=4 et

insert
<?php

/**
 * @covers SOMECLASS
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/g
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
        $user = new Webuser;

        $mock = $this->getMockPage($db, $config, $user);

        $assignments = [];
        $mock = $this->captureAssignments(
            $this->getMockPage($db, $config, $user),
            $assignments
        );

        $reflector = new ReflectionClass($mock);

        $meth = $reflector->getMethod('SOMEMETHOD');
        $meth->setAccessible(true);
        $actual = $meth->invokeArgs($mock, [&$REQUEST]);

        $expected = [
        ];

        $message = "U wot m8?";
        $this->assertEquals($expected, $actual, $message);
    }

    private function injectMembers(object $mock, ...$members): object {
        $reflector = new ReflectionClass($mock);
        $classMap = [
            ConfigUtil::class => 'config',
            PDO::class => 'database',
            Person::class => 'user',
        ];
        foreach ($members as $idx => $val) {
            $fld = null;
            if (is_int($idx)) {
                if (is_object($val)) {
                    foreach ($classMap as $type => $_f) {
                        if (get_class($val) === $type) {
                            $fld = $_f;
                        } elseif (is_a($val, $type)) {
                            $looseFit = $_f;
                        }
                    }
                    if (!isset($fld) && isset($looseFit)) {
                        $fld = $looseFit;
                    }
                }
            } else {
                $fld = $idx;
            }
            if (isset($fld)) {
                $prop = $reflector->getProperty($fld);
                $prop->setAccessible(true);
                $prop->setValue($mock, $val);
            } else {
                trigger_error("Unable to inject member at index $idx", E_USER_NOTICE);
            }
        }
        return $mock;
    } // end injectMembers()

    private function captureAssignments(TemplateRequest $mock, &$assignments): TemplateRequest {
        $acb = function ($key, $val) use (&$acb, &$assignments) {
            if (is_array($key)) {
                foreach ($key as $k => $v) {
                    $acb($k, $v);
                }
            } else {
                $assignments[$key] = $val;
            }
        };
        $mock->expects($this->any())
            ->method('assign')
            ->will($this->returnCallback($acb));
        return $mock;
    } // end captureAssignments()

    private function getMockPage(...$members): TemplateRequest {
        $mock = $this->getMockBuilder(SOMECLASS::class)
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/g
append
            ->setMethods([
                'assign',
                'dieString',
            ])
            ->disableOriginalConstructor()
            ->getMock();
        return $this->injectMembers($mock, ...$members);
    } // end getMockPage()

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
