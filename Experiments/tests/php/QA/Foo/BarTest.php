<?php
namespace QA\Foo;

class BarTest extends  \PHPUnit_Framework_TestCase
{
    public function testBar()
    {
        $bar = new Bar();
        $bar->outputSomething();

        $this->assertTrue(true);
    }
}
