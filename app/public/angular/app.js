"use strict";angular.module("myApp",["ngRoute","myApp.filters","myApp.services","myApp.directives"]).config(["$routeProvider",function(t){return t.when("/index",{templateUrl:"/index",controller:"ConceptMapperCtrl"}),t.otherwise({redirectTo:"/index"})}]);