<?php

class EcEventReportTest extends EcDatabaseTestCase {

    const DATADIR = 'EcEventReportTestData';

    public function getDataSet() {
        $yaml = __DIR__.'/'.static::DATADIR.'/dataset.yaml';
        return new PHPUnit_Extensions_Database_DataSet_YamlDataSet($yaml);
    }

    /**
     * Tests normal operation
     * @covers EcEventReport::getFilterSelections
     */
    public function testgetFilterSelections() {
        $db = $this->getDatabase();
        $user = new Webuser;
        $user->person_id = 1;
        $tconfig = new ConfigUtilTestWrapper;
        $tconfig->setPersonConfig($user->person_id, 'default_event_list_filters', '{"person":["all"],"event_type":["Calendar Item"],"event_name":"test","event_code":"","start_date":"","end_date":""}');
        $tclass = new EcEventReportWrapper($db, null, $user);
        $tclass->_setConfig($tconfig);
        $request = [];

        $expected_out = [
            'person' => ['all'],
            'event_type' => ['Calendar Item'],
            'event_name' => 'test',
            'event_code' => '',
            'start_date' =>'',
            'end_date' => '',
        ];
        $actual_out = $tclass->public_getFilterSelections($request);
        $this->assertEquals($expected_out, $actual_out, 'Failed to get expected user filters');
    }

    /**
     * Tests normal operation
     * @covers EcEventReport::assignFilterSelections
     * @uses EcEventReport::getFilterSelections
     */
    public function testassignFilterSelections() {
        $db = $this->getDatabase();
        $user = new Webuser;
        $user->person_id = 1;
        $tconfig = new ConfigUtilTestWrapper;
        $tconfig->setPersonConfig($user->person_id, 'default_event_list_filters', '{"person":["all"],"event_type":["Calendar Item"],"event_name":"test","event_code":"","start_date":"","end_date":""}');
        $tclass = new EcEventReportWrapper($db, null, $user);
        $tclass->_setConfig($tconfig);
        $request = [
            'user_defaults' => 'true',
        ];

        $expected_out = [
            'filter_selections' => '{"person":["all"],"event_type":["Calendar Item"],"event_name":"test","event_code":"","start_date":"","end_date":""}',
        ];
        $tclass->public_assignFilterSelections($request);
        $actual_out = $tclass->_assignments;
        $this->assertEquals($expected_out, $actual_out, 'Failed to assign expected filters');
    }
}

class EcEventReportWrapper extends EcEventReport {

    use TestOutputCapture;

    public function public_getFilterSelections(&$request) {
        return parent::getFilterSelections($request);
    }

    public function public_assignFilterSelections(&$request) {
        parent::assignFilterSelections($request);
    }

    // same thing except without classes
    public function __construct(PDO &$db, $smarty, $user) {
        $this->database = $db;
        $this->smarty = $smarty;
        $this->user = $user;
    }

    public function _setConfig($config) {
        $this->config = $config;
    }
}
