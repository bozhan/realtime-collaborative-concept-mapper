"use strict";var socketServer;socketServer=document.domain,angular.module("myApp.services",[]).value("version","0.2.2").factory("Socket",["$rootScope",function(t){var e,o;return o={},e=io.connect(socketServer),o.emit=function(t,o){return e.emit(t,o)},o.on=function(o,n){return e.on(o,function(e){return t.$apply(function(){return n(e)})})},o}]);