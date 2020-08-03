" mock object generation for phpunit tests
" vi: et

append
        $mock = $this->getMockBuilder(CLASS::class)
.
s/CLASS/\=expand("%:t:r:s?Test$??")/
append
            ->setMethods([
                'MYSTUB',
            ])
            ->disableOriginalConstructor()
            ->getMock();
        $mock->expects($this->once())
            ->method('MYSTUB')
            ->with($this->equalTo('ARG'))
            ->will($this->returnValue('RETURN'));
.
