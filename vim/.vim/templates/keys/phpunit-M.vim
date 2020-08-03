" method reflection for phpunit tests
" vi: et

insert

        $reflector = new ReflectionClass($mock);
        $meth = $reflector->getMethod('MYMETHOD');
        $meth->setAccessible(true);
        $out = $meth->invoke($mock, $MYARG);

.
