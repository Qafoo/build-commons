<?php

namespace @archtype.bundle.namespace@\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class DefaultController extends Controller
{
    public function indexAction()
    {
        return $this->render('@archtype.bundle.name@:Default:index.html.twig');
    }
}