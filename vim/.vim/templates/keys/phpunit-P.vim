" property reflection for phpunit tests
" vi: et

insert

        $reflector = new ReflectionClass($mock);
        $prop = $reflector->getProperty('MYPROPERTY');
        $prop->setAccessible(true);
        $prop->setValue($mock, $MYPROPERTY);

.
