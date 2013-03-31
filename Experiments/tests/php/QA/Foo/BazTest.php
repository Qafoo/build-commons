<?php
namespace QA\Foo;

class BazTest extends  \PHPUnit_Framework_TestCase
{
    public function testBar()
    {
        $bar = new Baz();
        $bar->outputSomething();

        $this->assertTrue(true);
    }
}
