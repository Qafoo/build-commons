<?php
namespace QA;

class FooTest extends  \PHPUnit_Framework_TestCase
{
    public function testFoo()
    {
        $foo = new Foo();

        $this->assertEquals(42, $foo->doSomething());

    }
}
