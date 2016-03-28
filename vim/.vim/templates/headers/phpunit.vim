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

        $expected_out = [
        ];
        $actual_out = $tclass->public_ SOMEMETHOD();

        $message = "U wot m8?";
        $this->assertEquals($expected_out, $actual_out, $message);

    }

    public function getDataSet() {
        $yaml = __DIR__.'/'.static::DATADIR.'/dataset.yaml';
        return new PHPUnit_Extensions_Database_DataSet_YamlDataSet($yaml);
    }

}

class SOMECLASS Wrapper extends SOMECLASS {
    // wrap expose some methods

    public function public_ SOMEMETHOD() {
        return static::SOMEMETHOD();
    }

    // same thing except without classes
    public function __construct(PDO &$db, $smarty, $user) {
        $this->database = $db;
        $this->smarty = $smarty;
        $this->user = $user;
    }

}
.
