"use strict";var _base,_base1;window.ut||(window.ut={}),(_base=window.ut).commons||(_base.commons={}),(_base1=window.ut.commons).persistency||(_base1.persistency={}),window.ut.commons.persistency.FileStorage=function(){function t(){console.log("Initializing ut.commons.persistency.FileStorage.")}return t.prototype.storeAsFile=function(t,e){var o,n;return o=new Blob([JSON.stringify(t)],{type:"text/json"}),-1!==navigator.appName.indexOf("Internet Explorer")?window.navigator.msSaveBlob(o,e):(n=document.createElement("a"),n.download=e,window.URL=window.webkitURL||window.URL,n.href=window.URL.createObjectURL(o),document.body.appendChild(n),n.click(),document.body.removeChild(n))},t.prototype.getFileFromDialog=function(t){var e;return e=document.createElement("input"),e.type="file",e.addEventListener("change",function(){var e;return e=this.files[0],e?t(void 0,e):t("ut.commons.persistency.FileStorage: no file selected.",void 0)}),e.style.display="none",document.body.appendChild(e),e.click(),document.body.removeChild(e)},t.prototype.getJSonObjectFromDialog=function(t){return this.getFileFromDialog(function(e,o){var n,r;if(e)return t(e,void 0);try{return r=new FileReader,r.onload=function(e){var o,n;try{return n=JSON.parse(e.target.result),t(void 0,n)}catch(r){return o=r,t("ut.commons.persistency: could not parse json.",void 0)}},r.readAsText(o)}catch(i){return n=i,t("ut.commons.persistency: could not read.",void 0)}})},t}();