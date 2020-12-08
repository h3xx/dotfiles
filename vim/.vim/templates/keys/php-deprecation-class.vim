" insert a deprecation warning for a constuctor

append
public function __construct() {
trigger_error('Deprecated class: '.__CLASS__);
}
.
