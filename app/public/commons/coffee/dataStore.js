"use strict";var EventEmitter,__hasProp={}.hasOwnProperty,__extends=function(t,e){function o(){this.constructor=t}for(var n in e)__hasProp.call(e,n)&&(t[n]=e[n]);return o.prototype=e.prototype,t.prototype=new o,t.__super__=e.prototype,t};window.ut=window.ut||{},ut.commons=ut.commons||{},EventEmitter=window.EventEmitter,ut.commons.DataStore=function(t){function e(){this.datas={}}return __extends(e,t),e.prototype.addData=function(t,e){var o;return null==(o=this.datas)[t]&&(o[t]=[]),this.datas[t].push(e)},e.prototype.getDatas=function(t){var e;return null!=(e=this.datas)[t]?(e=this.datas)[t]:e[t]=[]},e.prototype.getData=function(t,e){var o,n,i,r;for(r=this.getDatas(t),n=0,i=r.length;i>n;n++)if(o=r[n],o.title===e)return o;return null},e.prototype.getCategories=function(){var t,e,o,n;o=this.datas,n=[];for(e in o)t=o[e],n.push(e);return n},e.prototype.sendLoadEvent=function(t){return this.emitEvent("loadData",[t])},e}(EventEmitter);