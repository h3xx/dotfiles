" insert a deprecation warning
"    trigger_error(
"   'Undefined property via __get(): ' . $name .
"   ' in ' . $trace[0]['file'] .
"   ' on line ' . $trace[0]['line'],
"   E_USER_NOTICE);

append
trigger_error('Deprecated function: '.__CLASS__.'::'.__FUNCTION__, E_USER_DEPRECATED);
.
