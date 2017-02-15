" method reflection for php unit tests

insert

        $reflector = new ReflectionClass($tclass);
        $meth = $reflector->getMethod('MYMETHOD');
        $meth->setAccessible(true);
        $out = $meth->invoke($tclass, $MYARG);

.
