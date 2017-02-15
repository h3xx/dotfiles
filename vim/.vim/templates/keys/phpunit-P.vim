" property reflection for php unit tests

insert

        $reflector = new ReflectionClass($tclass);
        $prop = $reflector->getProperty('MYPROPERTY');
        $prop->setAccessible(true);
        $prop->setValue($tclass, $MYPROPERTY);

.
