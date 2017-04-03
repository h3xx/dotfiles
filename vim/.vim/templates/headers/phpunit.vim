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

        $format_data_f = function($rec) {
            if (empty($rec)) {
                return 'NORECORD';
            }

            return implode(' ',
                array_map(
                    function ($fld)
                    use (&$rec) {
                        return "$fld:{$rec->$fld}";
                    },
                    [
                        'field1',
                        'field2',
                    ]
                )
            );

        };

        $tclass = new SOMECLASS($db, null, null);
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/
append
        $reflector = new ReflectionClass($tclass);
        $meth = $reflector->getMethod('SOMEMETHOD');
        $meth->setAccessible(true);
        $actual_out = $meth->invokeArgs($tclass, [$MYARG]);

        $expected_out = [
        ];

        $message = "U wot m8?";
        $this->assertEquals($expected_out, $actual_out, $message);

    }

}

class SOMECLASSWrapper extends SOMECLASS {
.
s/SOMECLASS/\=expand("%:t:r:s?Test$??")/g
append
    use TestOutputCapture;

    // same thing except without classes
    public function __construct(PDO &$db, $smarty, $user) {
        $this->database = $db;
        $this->smarty = $smarty;
        $this->user = $user;
    }

}
.
