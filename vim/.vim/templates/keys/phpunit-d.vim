" data set equality assertion for phpunit tests

append
        $expected = $this->createArrayDataSet([
            'TABLE' => [
                [
                    'FIELD1' => 'VALUE1',
                ],
            ],
        ]);

        $actual = new \PHPUnit_Extensions_Database_DataSet_QueryDataSet($this->getConnection());
        $actual->addTable('TABLE', "
            select
                FIELD1
            from
                TABLE
            where
                ID = 101
        ");

        $message = "U wot m8?";
        $this->assertDataSetsEqual($expected, $actual, $message);
.
