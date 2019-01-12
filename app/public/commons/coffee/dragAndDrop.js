"use strict";var angular,clearDragAndDropTransferObject,collectDraggableInformation,currentDragAndDropTransferObject,dropAllowedStateClass,dummy,getDragAndDropTransferObject,isDropped,setDragAndDropTransferObject,showDropAllowedState,showDropNotAllowedState,startShowDropAllowedState,stopShowDropAllowedState;window.ut=window.ut||{},ut.commons=ut.commons||{},angular=window.angular,dropAllowedStateClass="dropObjectOutSideDropArea",startShowDropAllowedState=function(t){return showDropNotAllowedState(t)},stopShowDropAllowedState=function(t){return showDropAllowedState(t)},isDropped=function(t){return!t.hasClass(dropAllowedStateClass)},showDropNotAllowedState=function(t){return t.hasClass("ui-dialog")?void 0:t.addClass(dropAllowedStateClass)},showDropAllowedState=function(t){return t.removeClass(dropAllowedStateClass)},currentDragAndDropTransferObject=null,setDragAndDropTransferObject=function(t){return currentDragAndDropTransferObject=t},getDragAndDropTransferObject=function(){return currentDragAndDropTransferObject},clearDragAndDropTransferObject=function(){return currentDragAndDropTransferObject=null},collectDraggableInformation=function(t,e,o){var n,r,i,c,a,s,l;return i=t.attr("objectType"),r=t.attr("objectId"),n=e.offset(),l=t.offset(),s={left:l.left-n.left,top:l.top-n.top},a={dropObjectType:i,dropObjectId:r,objectDropLocation:s,dragAndDropTransferObject:getDragAndDropTransferObject()},o&&(c=ut.commons.utils.getAttributeValue(o,"dropTargetType"),c&&(a.dropTargetType=c)),a},dummy={helper:null,objectDraggingStarted:null,objectDraggingStopped:null,getDragAndDropTransferObject:null,objectDroppedOutside:null},ut.commons.golabUtils.directive("draggable",function(){return{restrict:"A",link:function(t,e,o){var n,r,i;return r={},n=function(t,e){var n;return n=t.toLowerCase(),o[n]?r[t]=o[n]:e?r[t]=e:void 0},n("helper"),n("revert"),n("revertDuration"),i=null,r.start=function(o,n){var r,c,a;return a=angular.element(n.helper),i=a.css("z-index"),r=10,"number"==typeof i&&(r+=i),a.css("z-index",r),startShowDropAllowedState(a),c=collectDraggableInformation(a,e),t.objectDraggingStarted&&(t.objectDraggingStarted(c,a),t.$apply()),t.getDragAndDropTransferObject?setDragAndDropTransferObject(t.getDragAndDropTransferObject(c,a)):void 0},r.stop=function(o,n){var r,c,a;return c=angular.element(n.helper),a=isDropped(c),c.css("z-index",i),stopShowDropAllowedState(c),r=collectDraggableInformation(c,e),a||t.objectDroppedOutside&&(t.objectDroppedOutside(r,c),t.$apply()),t.objectDraggingStopped&&t.objectDraggingStopped(r,c),clearDragAndDropTransferObject()},e.draggable(r),e.css("cursor","move")}}}),dummy={acceptObjectDrop:null,objectDroppedInside:null},ut.commons.golabUtils.directive("droppable",function(){return{restrict:"A",link:function(t,e,o){var n,r,i,c;return i=function(t,e){var o;return o=angular.element(e.helper),showDropAllowedState(o)},c=function(t,e){var o;return o=angular.element(e.helper),showDropNotAllowedState(o)},n=function(n){var r;return t.acceptObjectDrop?(r=angular.element(n),t.acceptObjectDrop(collectDraggableInformation(r,e,o),r)):!0},r=function(n,r){var i;return i=angular.element(r.helper),"function"==typeof t.objectDroppedInside&&t.objectDroppedInside(collectDraggableInformation(i,e,o),i),stopShowDropAllowedState(i),t.$apply()},e.droppable({over:function(t,e){return i(t,e)},out:function(t,e){return c(t,e)},accept:function(t){return n(t)},drop:function(t,e){return r(t,e)},tolerance:"pointer"})}}});