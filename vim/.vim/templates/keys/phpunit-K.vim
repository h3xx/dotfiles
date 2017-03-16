" mock object generation for php unit tests

append
        $mock = $this->getMockBuilder('CLASS')
.
s/CLASS/\=expand("%:t:r")/
append
            ->setMethods([
                'MYSTUB',
            ])
            ->disableOriginalConstructor()
            ->getMock();
        $mock->expects($this->once())
            ->method('MYSTUB')
            ->will($this->returnValue(false));
.
