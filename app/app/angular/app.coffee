"use strict"

###
  Declare app level module which depends on filters, services, and directives
###

angular.module("myApp", ['ngRoute', "myApp.filters", "myApp.services", "myApp.directives"])
.config ["$routeProvider",
  ($routeProvider) ->
    $routeProvider.when "/index", {templateUrl: "/index", controller: 'ConceptMapperCtrl'}
    $routeProvider.otherwise {redirectTo: "/index"}
  ]
#angular.module('myApp', []).controller('ConceptMapperCtrl', window.ut.tools.conceptmapper.ConceptMapper)


