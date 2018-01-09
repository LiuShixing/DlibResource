Array.implement({hsv2rgb:function(){var e=this,t,n,r,i,s,o=e[0]/360,u=e[1]/100,a=e[2]/100;return u?(o=o>1?0:6*o,s=o|0,n=a*(1-u),r=a*(1-u*(o-s)),i=a+n-r,t=s==0?[a,i,n]:s==1?[r,a,n]:s==2?[n,a,i]:s==3?[n,r,a]:s==4?[i,n,a]:[a,n,r]):t=[a,a,a],t.map(function(e){return.5+e*255|0})},rgb2hsv:function(){var e=this,t=0,n=0,r=255,i=e[0]/r,s,o=e[1]/r,u,a=e[2]/r,f,l=[i,o,a].max(),c=l-[i,o,a].min();return c&&(n=c/l,r=c/2,s=((l-i)/6+r)/c,u=((l-o)/6+r)/c,f=((l-a)/6+r)/c,t=i==l?f-u:o==l?1/3+s-f:2/3+u-s,t<0&&(t+=1),t>1&&(t-=1)),[t*360,n*100,l*100]}});var Dialog=new Class({Implements:[Events,Options],options:{cssShow:"show",cssClass:"",styles:{},relativeTo:document.body},initialize:function(e){var t=this,n;this.setClass(".dialog",e),this.setOptions(e),console.log("Dialog.initialize"),e=t.options,n=t.element=e.dialog||t.build(e),n.getElements(".close").addEvent("click",t.hide.bind(t)),n.getStyle("position")=="absolute"&&e.draggable&&new Drag(n,{handle:(t.get(".caption")||n).setStyle("cursor","move")}),t[e.showNow?"show":"hide"]()},toElement:function(){return this.element},get:function(e){return this.element.getElement(e)},setClass:function(e,t){t.cssClass=e+(t.cssClass||""),console.log("Dialog.setClass ",t.cssClass)},destroy:function(){this.element.destroy()},show:function(){this.fireEvent("beforeOpen",this);if(!this.options.draggable||!this.hasPosition)this.setPosition(),this.hasPosition=!0;return this.element.addClass(this.options.cssShow),this.fireEvent("open",this)},hide:function(){return this.hasPosition&&(this.fireEvent("beforeClose",this).element.removeClass(this.options.cssShow),this.fireEvent("close",this)),this},isVisible:function(){return this.element.hasClass(this.options.cssShow)},toggle:function(){return this[this.isVisible()?"hide":"show"]()},action:function(e){console.log("Dialog action: ",e," close:"+this.options.autoClose),this.fireEvent("action",e),this.options.autoClose&&this.hide()},build:function(e){console.log("DIALOG build ",e.cssClass,e.styles);var t=this.element=["div"+e.cssClass,{styles:e.styles},["a.close",{html:"&#215;"},"div.body"]].slick().inject(document.body);return e.relativeTo&&t.inject($(e.relativeTo),"before"),this.setBody(e.body),e.caption&&this.setCaption(e.caption),t},setBody:function(e){var t=this.get(".body")||this.element,n=typeOf(e);return t.empty(),n=="string"&&t.set("html",e),n=="element"&&t.adopt(e),n=="elements"&&t.adopt(e),this},setCaption:function(e){var t=this.get(".caption")||"div.caption".slick().inject(this.element,"top");return type=typeOf(e),t.empty(),type=="string"&&t.set("html",e),type=="element"&&t.adopt(e),this},setValue:function(e){return console.log("DIALOG  "+e),this.setBody(e)},setPosition:function(e){var t=window,n,r,i,s,o=this.element;return e||(e=this.options.relativeTo),s=e&&"getCoordinates"in e?e:document.id(e),s?(s=s.getCoordinates(),r=s.left,i=s.bottom):(n=t.getScroll(),t=t.getSize(),s=o.getCoordinates(),r=n.x+t.x/2-s.width/2,i=n.y+t.y/2-s.height/2),o.setPosition({x:r,y:i}),this}});Dialog.Buttons=new Class({Extends:Dialog,options:{buttons:[],autoClose:!0},initialize:function(e){this.setClass(".buttons",e),this.parent(e),this.setButtons(this.options.buttons)},setButtons:function(e){var t=this,n=t.get(".btn-group")||"div.btn-group".slick().inject(t.element);return n.empty().adopt(e.map(function(e){return"a.btn.btn-default.btn-sm".slick({html:e.localize(),events:{click:t.action.bind(t,e)}})})),t}}),Dialog.Color=new Class({Extends:Dialog,options:{color:"#ffffff",resize:{x:[96,256]}},initialize:function(e){var t=this,n,r=e.showNow,i=t.setHSV.bind(this);this.setClass(".color",e),e.caption="span.color".slick(),e.body=["div.cursor","div.zone"].slick(),n=t.cursor=e.body[0],e.showNow=!1,t.parent(e),new Drag(n,{handle:n.getNext(),style:!1,snap:0,onStart:i,onDrag:i}),t.setValue(),r&&t.show()},setValue:function(e){return e=(e||this.options.color).hexToRgb(!0)||[255,255,255],this.hsv=e.rgb2hsv(),this.moveCursor()},setHSV:function(e,t){var n=this,r=n.get(".body").getCoordinates(),i=[t.page.x-r.left,t.page.y-r.top],s=r.width,o=s/2,u=o/2,a=i[0]-o,f=s-i[1]-o,l=Math.sqrt(Math.pow(a,2)+Math.pow(f,2)),c=Math.atan2(a,f)/(Math.PI*2);n.hsv=[c>0?c*360:c*360+360,l<u?l/u*100:100,l>=u?Math.max(0,1-(l-u)/u)*100:100],n.moveCursor(),n.fireEvent("drag",n.getHex())},getHex:function(){return this.hsv.hsv2rgb().rgbToHex()},action:function(e){this.parent(this.getHex())},show:function(){return this.parent().moveCursor()},moveCursor:function(){var e=this,t=e.hsv,n=e.getHex(),r=e.get(".body").getSize().x/2,i=t[0]/360*Math.PI*2,s=(t[1]+(100-t[2]))/100*(r/2);return e.get(".color").set({html:n,styles:{color:(new Color(n)).invert().hex,background:n}}),e.cursor.setStyles({left:Math.abs(Math.sin(i)*s+r),top:Math.abs(Math.cos(i)*s-r)}),e}}),Dialog.Selection=new Class({Extends:Dialog,options:{cssClass:"dialog selection",autoClose:!0},initialize:function(e){this.setClass(".selection",e),this.selected=e.selected||"",this.parent(e)},setBody:function(e){var t=this,n=[];return e||(e=t.options.body),typeOf(e)=="string"&&(e=e.split("|")),typeOf(e)=="array"&&(e=e.associate(e)),typeOf(e)=="object"&&(Object.each(e,function(e,t){n.push(e==""?"li.divider":"li.item[title="+t+"]",{html:e})}),e=["ul",n].slick()),typeOf(e)=="element"&&(t.parent(e).setValue(t.selected),t.element.addEvent("click:relay(.item)",function(e){e.stop(),t.action(this.get("title"))})),t},setValue:function(e){var t=this,n="selected",r;return r=t.get("."+n),r&&r.removeClass(n),r=t.get(".item[title^="+e+"]"),r&&r.addClass(n),t[n]=e,t},getValue:function(){return this.selected},action:function(e){this.setValue(e).parent(e)}}),Dialog.Font=new Class({Extends:Dialog.Selection,options:{fonts:{"arial, helvetica, sans-serif":"Sans Serif","times new roman, serif":"Serif",monospace:"Fixed Width","arial black, sans-serif":"Wide","arial narrow, sans-serif":"Narrow",divider1:"","comic sans ms":"Comic Sans","courier new":"Courier New",garamond:"Garamond",georgia:"Georgia",helvetica:"Helvetica","HelveticaNeue-Light":"Helvetica Neue Light",impact:"Impact","times new roman":"Times New Roman",tahoma:"Tahoma","trebuchet ms":"Trebuchet",verdana:"Verdana"}},initialize:function(e){var t=this,n=e.fonts;t.setClass(".font",e),e.body=e.fonts||t.options.fonts,t.parent(e),t.element.getElements(".item").each(function(e){e.setStyle("font-family",e.get("title"))})}}),Dialog.Chars=new Class({Extends:Dialog.Selection,options:{chars:["lsquo|rsquo|ldquo|rdquo|lsaquo|rsaquo|laquo|raquo|apos|quot|sbquo|bdquo","ndash|mdash|sect|para|dagger|Dagger|amp|lt|gt|copy|reg|trade","rarr|rArr|bull|middot|deg|plusmn|brvbar|times|divide|frac14|frac12|frac34","hellip|micro|cent|pound|euro|iquest|iexcl|uml|acute|cedil|circ|tilde","Agrave|Aacute|Acirc|Atilde|Auml|Aring|AElig|Ccedil|Egrave|Eacute|Ecirc|Euml","Igrave|Iacute|Icirc|Iuml|ETH|Ntilde|Ograve|Oacute|Ocirc|Otilde|Ouml|Oslash","OElig|Scaron|Ugrave|Uacute|Ucirc|Uuml|Yacute|Yuml|THORN|szlig|agrave|aacute","acirc|atilde|auml|aring|aelig|ccedil|egrave|eacute|ecirc|euml|igrave|iacute","icirc|iuml|eth|ntilde|ograve|oacute|ocirc|otilde|ouml|oslash|oelig|scaron","ugrave|uacute|ucirc|uuml|yacute|yuml|thorn|ordf|ordm|alpha|Omega|infin","not|sup2|sup3|permil|larr|uarr|darr|harr|hArr|crarr|loz|diams"]},initialize:function(e){this.setClass(".chars",e),this.parent(e)},setBody:function(){var e=[];return this.options.chars.map(function(t){var n=[];t.split("|").each(function(e){n.push("td.item[title=&"+e+";]",{html:"&"+e+";"})}),e.push("tr",n)}),this.parent(["table",e].slick())}}),Dialog.Find=new Class({Extends:Dialog,Binds:["find","replace"],options:{draggable:!0,controls:{f:"[name=tbFIND]",r:"[name=tbREPLACE]",h:".tbHITS",re:"[name=tbREGEXP]",i:"[name=tbMatchCASE]",one:"[name=replace]",all:"[name=replaceall]"},data:{get:function(){},set:function(){}}},initialize:function(e){var t=this.setOptions(e),n=t.options.dialog,r;this.setClass(".find",e),r=t.controls=Object.map(t.options.controls,function(e){return n.getElement(e)}),t.parent(e),r.f.addEvents({keyup:t.find,focus:t.find}),n.addEvents({"change:relay([type=checkbox])":function(){r.f.focus()},"click:relay(button)":t.replace})},show:function(){this.parent(),this.controls.f.focus()},find:function(){var e=this,t=e.controls,n=t.f.value,r,i,s="disabled";n!=""&&(r=e.buildRE(n),r instanceof RegExp&&(r=e.options.data.get().match(e.buildRE(n,!0)),r&&(r=r.length))),t.h&&(t.h.innerHTML=r||""),i=+r?"erase":"set",t.r[i](s,s),t.one[i](s,s),t.all[i](s,s),t.f.focus()},replace:function(e){var t=this,n=t.controls,r=n.r,i=n.f,s=t.options.data;s.set(s.get().replace(t.buildRE(i.value,e.target==n.all),r?r.value:"")),i.focus()},buildRE:function(e,t){var n=this.controls,r=n.re&&n.re.checked,i=t?"g":"",s=n.i&&n.i.checked?"":"i";try{return RegExp(r?e:e.escapeRegExp(),i+s+"m")}catch(o){return"<span title='"+o+"'>!#@</span>"}}});var Textarea=new Class({Implements:[Options,Events],initialize:function(e,t){var n=this,r=n.ta=document.id(e);return n.setOptions(t),n.taShadow="div[style=position:absolute;visibility:hidden;overflow:auto]".slick().setStyles(r.getStyles("font-family0font-size0line-height0text-indent0padding-top0padding-right0padding-bottom0padding-left0border-left-width0border-right-width0border-left-style0border-right-style0white-space0word-wrap".split(0))),this},toElement:function(){return this.ta},getValue:function(){return this.ta.value},slice:function(e,t){return this.ta.value.slice(e,t)},indexOf:function(e,t){return this.ta.value.indexOf(e,t)},getFromStart:function(){return this.slice(0,this.getSelectionRange().start)},getTillEnd:function(){return this.slice(this.getSelectionRange().end)},getSelection:function(){var e=this.getSelectionRange();return this.slice(e.start,e.end)},setSelectionRange:function(e,t){var n=this.ta,r,i,s;return t||(t=e),n.setSelectionRange?n.setSelectionRange(e,t):(r=n.value,i=r.slice(e,t-e).replace(/\r/g,"").length,e=r.slice(0,e).replace(/\r/g,"").length,s=n.createTextRange(),s.collapse(!0),s.moveEnd("character",e+i),s.moveStart("character",e),s.select()),this},getSelectionRange:function(){var e=this.ta,t=0,n=0,r,i,s,o;return e.selectionStart!=null?(t=e.selectionStart,n=e.selectionEnd):(r=document.selection.createRange(),r&&r.parentElement()==e&&(i=r.duplicate(),s=e.value,o=s.length-s.match(/[\n\r]*$/)[0].length,i.moveToElementText(e),i.setEndPoint("StartToEnd",r),n=o-i.text.length,i.setEndPoint("StartToStart",r),t=o-i.text.length)),{start:t,end:n,thin:t==n}},setSelection:function(){var e=Array.from(arguments).join("").replace(/\r/g,""),t=this.ta,n=t.scrollTop,r,i,s,o;return t.selectionStart!=null?(r=t.selectionStart,i=t.selectionEnd,s=t.value,t.value=s.slice(0,r)+e+s.substr(i),t.selectionStart=r,t.selectionEnd=r+e.length):(t.focus(),o=document.selection.createRange(),o.text=e,o.collapse(1),o.moveStart("character",-e.length),o.select()),t.focus(),t.scrollTop=n,this},insertAfter:function(){var e=Array.from(arguments).join("");return this.setSelection(e).setSelectionRange(this.getSelectionRange().start+e.length)},isCaretAtStartOfLine:function(){var e=this.getSelectionRange().start;return e<1||this.ta.value.charAt(e-1).test(/[\n\r]/)},isCaretAtEndOfLine:function(){var e=this.getSelectionRange().end;return e==this.ta.value.length||this.slice(e-1,e+1).test(/[\n\r]/)},getCoordinates:function(e){var t=this.ta,n=this.taShadow.inject(t,"before"),r=t.value,i,s,o,u,a;return e||(e=this.getSelectionRange().end),i=n.set({styles:{width:t.offsetWidth,height:t.getStyle("height")},html:r.slice(0,e)+"<i>A</i>"+r.slice(e+1)}).getElement("i"),s=t.offsetTop+i.offsetTop-t.scrollTop,o=t.offsetLeft+i.offsetLeft-t.scrollLeft,u=i.offsetWidth,a=i.offsetHeight,{top:s,left:o,width:u,height:a,right:o+u,bottom:s+a}}});!function(){function e(e){var t=e.btns,n="disabled";t.undo&&t.undo.ifClass(!e.undo[0],n),t.redo&&t.redo.ifClass(!e.redo[0],n)}function t(t,n){t=this[t],n=this[n],t[0]&&(n.push(this.getState()),this.putState(t.pop())),e(this)}this.Undoable=new Class({initializeUndoable:function(n,r){var i=this,s=i.undo=[];i.redo=[],i.btns=n,e(i),r=r||40,i.addEvents({beforeChange:function(t){s.push(t||i.getState()),i.redo=[],s[r]&&s.shift(),e(i)},undo:t.pass(["undo","redo"],i),redo:t.pass(["redo","undo"],i)})}})}();var Snipe=new Class({Implements:[Options,Events,Undoable],Binds:["sync","shortcut","keystroke","suggest","action"],options:{tab:"    ",snippets:{},directsnips:{},sectionCursor:"all",sectionParser:function(){return{}}},initialize:function(e,t){t=this.setOptions(t).options,this.initializeUndoable(t.undoBtns);var n=this,r=n.mainarea=$(e),i=r.clone().erase("name").inject(r.hide(),"before"),s=t.container||i.form,o=n.textarea=new Textarea(i);n.directsnips=new Snipe.Snips(o,t.directsnips),n.snippets=new Snipe.Snips(o,t.snippets),n.snippets.dialogs.find=[Dialog.Find,{data:{get:function(){var e=o.getSelection();return e==""?i.value:e},set:function(e){var t=o.getSelectionRange();n.fireEvent("beforeChange"),t.thin?i.value=e:o.setSelection(e)}}}],n.commands=new Snipe.Commands(s,{onClose:function(){i.focus()},onAction:n.action,dialogs:n.snippets.dialogs,relativeTo:o}),n.reset(),i.addEvents({keydown:n.keystroke,keypress:n.keystroke,keyup:n.suggest.debounce(),click:n.suggest.debounce(),change:function(e){n.fireEvent("change",e)}}),s.addEvent("keydown",n.shortcut)},toElement:function(){return $(this.textarea)},get:function(e){return/mainarea|textarea/.test(e)?this[e]:/snippets|directsnips|autosuggest|tabcompletion|smartpairs/.test(e)?this.options[e]:null},set:function(e,t){return/snippets|directsnips|autosuggest|tabcompletion|smartpairs/.test(e)&&(this.options[e]=t),this},shortcut:function(e){var t,n;if(e.shift||e.control||e.meta||e.alt)t=(e.shift?"shift+":"")+(e.control?"control+":"")+(e.meta?"meta+":"")+(e.alt?"alt+":"")+e.key,n=this.snippets.keys[t],n&&(console.log("Snipe shortcut",t,n,e.code),e.stop(),this.commands.action(n))},keystroke:function(e){if(e.type=="keydown"){if(e.key.length==1)return}else{if(!e.event.which)return;e.key=String.fromCharCode(e.code).toLowerCase()}var t=this,n=t.textarea,r=n.toElement(),i=e.key,s=n.getSelectionRange();r.focus(),/up|down|esc/.test(i)?t.reset():/tab|enter|delete|backspace/.test(i)?t[i](e,n,s):t.smartPairs(e,n,s)},enter:function(e,t,n){this.reset();var r=t.getFromStart().match(/(?:^|\r?\n)([ \t]+)(.*)$/);!e.shift&&r&&r[2]!=""&&(e.stop(),t.insertAfter("\n"+r[1]))},backspace:function(e,t,n){if(n.thin&&n.start>0){var r=t.getValue().charAt(n.start-1),i=this.directsnips.get(r);i&&i.snippet==t.getValue().charAt(n.start)&&t.setSelectionRange(n.start,n.start+1).setSelection("")}},"delete":function(e,t,n){var r=this.options.tab;n.thin&&!t.getTillEnd().indexOf(r)&&(e.stop(),t.setSelectionRange(n.start,n.start+r.length).setSelection(""))},tab:function(e,t,n){var r=this,i;e.stop();if(r.options.tabcompletion&&n.thin&&(i=r.snippets.match()))return t.setSelectionRange(n.start-i.length,n.start).setSelection(""),r.commands.action(i);r.tab2spaces(e,t,n)},tab2spaces:function(e,t,n){var r=this.options.tab,i=t.getSelection(),s=t.getFromStart();isCaretAtStart=t.isCaretAtStartOfLine(),i.indexOf("\n")>-1?(isCaretAtStart&&(i="\n"+i),e.shift?i=i.replace(RegExp("\n"+r,"g"),"\n"):i=i.replace(/\n/g,"\n"+r),t.setSelection(isCaretAtStart?i.slice(1):i)):e.shift?s.test(r+"$")&&t.setSelectionRange(n.start-r.length,n.start).setSelection(""):t.setSelection(r).setSelectionRange(n.start+r.length)},hasContext:function(){return!!this.context.snip},setContext:function(e,t){this.context={snip:e,suggest:t},this.toElement().addClass("activeSnip")},reset:function(){this.context={},this.commands.close(),this.toElement().removeClass("activeSnip").focus()},smartPairs:function(e,t,n){var r,i=e.key;this.options.smartpairs&&(r=this.directsnips.get(i))&&(e.stop(),t.setSelection(i,t.getSelection(),r.text).setSelectionRange(n.start+1,n.end+1))},suggest:function(e){var t=this,n;if(this.options.autosuggest){if(n=this.snippets.matchSuggest())return this.setContext(null,n),this.commands.action(n.cmd,n.pfx);this.reset()}t.fireEvent("change")},action:function(e){var t=this,n=Array.slice(arguments,1),r,i=t.textarea,s=i.getSelectionRange(),o,u;if(r=t.snippets.get(e)){if(r.event)return t.fireEvent(r.event,arguments);this.fireEvent("beforeChange");if(r.suggest)return t.suggestAction(e,n);o=r.text,!s.thin&&r.parms.length==2&&(o=t.toggleSnip(i,r,s));while(n&&n[0])r.parms[0]&&(o=o.replace(r.parms.shift(),n.shift()));r.parms[1]&&(s.thin||(u=r.parms.shift(),o=o.replace(u,i.getSelection()))),i.setSelection(o),s.thin&&(console.log("move after",o.length,s.start+o.length),i.setSelectionRange(s.start+o.length)),t.reset()}},toggleSnip:function(e,t,n){var r=t.text,i=r.trim().split(t.parms[0]),s=i[0],o=i[1],u=new RegExp("^\\s*"+s.trim().escapeRegExp()+"\\s*(.*)\\s*"+o.trim().escapeRegExp()+"\\s*$");return s+o!=""&&(r=e.getSelection(),t.parms=[],r.test(u)?r=r.replace(u,"$1"):e.getFromStart().test(s.escapeRegExp()+"$")&&e.getTillEnd().test("^"+o.escapeRegExp())?e.setSelectionRange(n.start-s.length,n.end+o.length):e.setSelection(s+o).setSelectionRange(n.start+s.length)),r},suggestAction:function(e,t){console.log(this.context.suggest);var n=this.context.suggest,r=this.textarea,i=r.getSelectionRange().start-n.pfx.length;return i=r.indexOf(n.match,i),i>=0&&r.setSelectionRange(i,i+n.match.length).setSelection(t).setSelectionRange(r.getSelectionRange().end),this.suggest()},nextAction:function(e,t){var n=this,r=n.context.snip,i=r.parms,s,o;while(i[0]){s=i.shift(),o=e.getValue().indexOf(s,t.start);if(s!=""&&o>-1){if(i[0]){e.setSelectionRange(o,o+s.length),n.commands.action(s,r[s]);return}e.setSelectionRange(o+s.length)}}n.reset()},getState:function(){var e=this.textarea,t=e.toElement();return{main:this.mainarea.value,value:t.get("value"),cursor:e.getSelectionRange(),scrollTop:t.scrollTop,scrollLeft:t.scrollLeft}},putState:function(e){var t=this,n=t.textarea,r=n.toElement();t.reset(),t.mainarea.value=e.main,r.value=e.value,r.scrollTop=e.scrollTop,r.scrollLeft=e.scrollLeft,n.setSelectionRange(e.cursor.start,e.cursor.end),t.fireEvent("change")}});Snipe.Snips=new Class({Implements:Events,initialize:function(e,t){var n=this,r,i,s,o,u=navigator.platform.match(/mac/i)?"meta+":"control+";n.workarea=e,n.snips=t,n.keys={},n.dialogs={},n.suggestions={};for(r in t){i=Function.from(t[r])(e,r),typeOf(i)=="string"&&(i={snippet:i});if(s=i.key)s.contains("+")||(s=u+s),n.keys[s.toLowerCase()]=r,i.key=s;if(o=i.suggest)typeOf(o)=="string"&&(i.suggest={pfx:RegExp(o+"$"),match:RegExp("^"+o)}),n.suggestions[r]=i;i[r]&&(n.dialogs[r]=i[r]),t[r]=i}},match:function(){var e,t=this.workarea.getFromStart();for(e in this.snips)if(t.test(e+"$"))return e;return!1},matchSuggest:function(){var e,t,n,r,i,s=this.suggestions,o=this.workarea,u=o.getSelectionRange(),a=o.getFromStart(),f=o.isCaretAtStartOfLine(),l=o.isCaretAtEndOfLine();for(e in s){t=s[e],i=t.suggest;if(this.inScope(t,a)){i.pfx?(n=a.match(i.pfx),n&&(console.log("SUGGEST Prefix ",e,i.pfx,n.getLast()),n=n.getLast(),r=o.slice(u.start-n.length).match(i.match),console.log("SUGGEST Match ",i.match,r),r&&(r={pfx:n,match:r.getLast()}))):r=Function.from(i)(o,u,a);if(r)return r.cmd=e,r}}return!1},get:function(e){var t=this,n=t.workarea,r=n.getFromStart(),i=t.snips[e],s=[],o,u;i&&i.synonym&&(i=t.snips[i.synonym]);if(!i||!t.inScope(i,r))return!1;o=i.snippet||"",o=o.replace(/\\?\{([^{}]+)\}/g,function(e,t){return e.charAt(0)=="{"?(s.push(t),t):e.slice(1)}).replace(/\\\{/g,"{"),u=s.getLast(),u&&s.push(o.slice(o.lastIndexOf(u)+u.length)),o.test(/^\n/)&&r.test(/(^|[\n\r]\s*)$/)&&(o=o.slice(1)),o.test(/\n$/)&&n.getTillEnd().test(/^\s*[\n\r]/)&&(o=o.slice(0,-1));var a=r.split(/\r?\n/).pop(),f=a.match(/^\s+/);return f&&(o=o.replace(/\n/g,"\n"+f[0])),i.text=o,i.parms=s,i},inScope:function(e,t){var n,r,i=e.scope,s=e.nscope;if(i){if(typeOf(i)=="function")return i(this.textarea);for(n in i){r=t.lastIndexOf(n);if(r>-1&&t.indexOf(i[n],r)==-1)return!0}return!1}if(s)for(n in s){r=t.lastIndexOf(n);if(r>-1&&t.indexOf(s[n],r)==-1)return!1}return 1},toggle:function(e,t,n){var r=t.text,i=r.trim().split(t.parms[0]),s=i[0],o=i[1],u=new RegExp("^\\s*"+s.trim().escapeRegExp()+"\\s*(.*)\\s*"+o.trim().escapeRegExp()+"\\s*$");return s+o!=""&&(r=e.getSelection(),t.parms=[],r.test(u)?r=r.replace(u,"$1"):e.getFromStart().test(s.escapeRegExp()+"$")&&e.getTillEnd().test("^"+o.escapeRegExp())?e.setSelectionRange(n.start-s.length,n.end+o.length):e.setSelection(s+o).setSelectionRange(n.start+s.length)),r}}),Snipe.Commands=new Class({Implements:[Events,Options],options:{cmds:"data-cmd"},dlgs:{},btns:{},dialogs:{},initialize:function(e,t){var n=this.setOptions(t),r=n.options.cmds,i,s,o=t.dialogs||{};e.addEvent("click:relay(["+r+"])",function(e){var t=this.get(r),i=n.dlgs[t];i?i.toggle():n.action(t),this.match("input")||e.stop()}),e.getElements("["+r+"]").each(function(u){i=u.get(r),n.btns[i]=u;if(s=e.getElement(".dialog."+i))o[i]||(o[i]=[Dialog,{}]),t=o[i][1],t.dialog=s.inject(document.body),t.relativeTo=u}),n.addDialogs(o)},addDialogs:function(e){var t,n,r=this.dialogs;for(n in e)r[n]&&console.log("Snipe.Commands addDialogs() - warning: double registration of => "+n),t=r[n]=e[n],instanceOf(t,Dialog)&&this.attach(t,n)},attach:function(e,t){var n=this,r=function(e){n.fireEvent("action",[t,e])};return console.log("Snipe.Commands: attachDialog() ",t,e),n.dlgs[t]=e.addEvents({open:n.openDialog.bind(n,t),close:n.closeDialog.bind(n,t),action:r,drag:r})},action:function(e,t){var n=this,r="active",i=n.btns[e],s;if(!i||!i.match(".disabled"))n.dialogs[e]?(s=n.dlgs[e]||n.createDialog(e),t!=null&&s.setValue(t),s.show()):(i&&i.addClass(r),n.fireEvent("action",[e,t]),i&&i.removeClass(r))},createDialog:function(e){var t=Function.from(this.dialogs[e])();return typeOf(t)!="array"&&(t=[Dialog.Selection,{body:t}]),t[1].relativeTo||(t[1].relativeTo=this.options.relativeTo||document.body),t[1].autoClose=!1,this.attach(new t[0](t[1]),e)},openDialog:function(e){var t=this,n=t.activeDlg,r=t.dlgs[e],i=t.btns[e];n&&n!=r&&n.hide(),t.activeDlg=t.dlgs[e],i&&i.addClass("active"),t.fireEvent("open",e)},closeDialog:function(e,t){var n=this,r=n.btns[e];n.dlgs[e]==n.activeDlg&&(n.activeDlg=null),r&&r.removeClass("active"),n.fireEvent("close",e)},close:function(){var e=this.activeDlg;e&&e.hide()}}),Snipe.Sections=new Class({Implements:[Events],Binds:["show","update","action"],options:{all:"( all )".localize(),startOfPage:"Start of Page".localize()},initialize:function(e,t){var n=this,r=t.snipe;n.container=e,n.parser=t.parser,n.list=e.getElement("ul").addEvent("click:relay(a)",n.action),n.main=r.get("mainarea"),n.work=$(r.get("textarea")).addEvents({keyup:n.update,change:n.update}),n.parse(),n.action(location.search),n.show()},parse:function(){this.sections=this.parser(this.main.value)},show:function(){var e=[],t=this.options,n=this.current,r=this.sections,i=function(t,r,i){e.push("li"+(i==n?".active":""),["a.indent-"+t+".section"+i,{html:r}])};i(0,t.all,-2),r[0]&&(r[0].start>0&&i(0,t.startOfPage,-1),e.push("li.divider"),r.each(function(e,t){i(e.depth,e.title,t)})),this.list.empty().adopt(e.slick())},update:function(){var e=this,t=e.main,n=e.work.value,r=t.value;n.slice(-1)!="\n"&&(n+="\n"),t.value=r.slice(0,e.begin)+n+r.slice(e.end),e.end=e.begin+n.length,e.parse()},action:function(e){var t=this,n=t.main.value,r=t.work,i=t.sections,s=0,o=n.length;return e&&(e.target&&(e=e.target.className),e=(e.match(/section=?(-?\d+)/)||[,-2])[1].toInt(),e==-1?o=i[0].start:e>=0&&i[e]&&(s=i[e].start,i[e+1]&&(o=i[e+1].start)),t.current=e),r.value=n.slice(s,o),r.setSelectionRange(0,0),t.begin=s,t.end=o,t.container.ifClass(e>=-1,"section-selected"),t.show(),r.fireEvent("change"),!1}}),Wiki.DirectSnips={'"':'"',"(":")","[":"]","{":"}","'":{snippet:"'",scope:{"[{":"}]"}}},Wiki.Snips={find:{key:"f"},undo:{key:"z",event:"undo"},redo:{key:"y",event:"redo"},smartpairs:{event:"config"},livepreview:{event:"config"},autosuggest:{event:"config"},tabcompletion:{event:"config"},previewcolumn:{event:"config"},wysiwyg:{event:"config"},br:{key:"shift+enter",snippet:"\\\\\n"},hr:"\n----\n",lorem:"This is just some sample. Don’t even bother reading it; you will just waste your time. Why do you keep reading? Do I have to use Lorem Ipsum to stop you? OK, here goes: Lorem ipsum dolor sit amet, consectetur adipi sicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Still reading? Gosh, you’re impossible. I’ll stop here to spare you.",Lorem:{synonym:"lorem"},bold:{key:"b",snippet:"__{bold}__ "},italic:{key:"i",snippet:"''{italic}'' "},mono:{key:"m",snippet:"\\{\\{{monospaced text}}} "},sub:"%%sub {subscript text}/% ",sup:"%%sup {superscript text}/% ",strike:"%%strike {strikethrough text}/% ",quote:"\n%%quote \n{Quoted text}\n/%\n",dl:"\n;{term}:{definition-text} ",pre:"\n\\{\\{\\{\n{some preformatted block}\n}}}\n",code:"\n%%prettify \n\\{\\{\\{\n{/* some code block */}\n}}}\n/%\n",table:"\n||{heading-1} ||heading-2\n|cell11     |cell12\n|cell21     |cell22\n",t:{synonym:"table"},me:{alias:"sign"},sign:function(){var e=Wiki.UserName||"UserName";return"\n\\\\ &mdash;"+e+", "+(new Date).toISOString()+"\\\\ \n"},date:function(e){return(new Date).toISOString()+" "},tabs:{nScope:{"%%(":")","%%tabbedSection":"/%"},snippet:"%%tabbedSection \n%%tab-{tabTitle1}\n{tab content 1}\n/%\n%%tab-{tabTitle2}\n{tab content 2}\n/%\n/%\n "},img:"\n[{Image src='img.jpg' width='400px' height='300px' align='{left}' }]\n ",imgSrcDlg:{scope:{"[{Image":"}]"},suggest:{pfx:"src='([^']*)'?$",match:"^([^']*)"},imgSrcDlg:[Dialog.Selection,{caption:"Image Source",onOpen:function(e){var t=e.getValue();if(!t||t.trim()=="")t=Wiki.PageName+"/";Wiki.jsonrpc("/search/suggestions",[t,30],function(t){console.log("jsonrpc result",t),t[1]?e.setBody(t):e.hide()})}}]},font:{nScope:{"%%(":")"},snippet:"%%(font-family:{font};) body /% "},fontDlg:{scope:{"%%(":")"},suggest:{pfx:"font-family:([^;\\)\\n\\r]*)$",match:"^([^;\\)\\n\\r]*)"},fontDlg:[Dialog.Font,{}]},color:"%%(color:{#000000}; background:#ffffff;) {some text} /%",colorDlg:{scope:{"%%(":")"},suggest:"#[0-9a-fA-F]{0,6}",colorDlg:[Dialog.Color,{}]},symbol:{synonym:"chars"},chars:"&entity;",charsDlg:{suggest:"&\\w+;?",charsDlg:[Dialog.Chars,{caption:"Special Chars".localize()}]},icon:"%%icon-{}search /%",iconDlg:{scope:{"%%":"/%"},suggest:"icon-\\S*",iconDlg:[Dialog.Selection,{cssClass:".dialog-horizontal",body:{"icon-search":"<div class='icon-search'></div>","icon-user":"<div class='icon-user'></div>","icon-home":"<div class='icon-home'></div>","icon-refresh":"<div class='icon-refresh'></div>","icon-repeat":"<div class='icon-repeat'></div>","icon-bookmark":"<div class='icon-bookmark'></div>","icon-tint":"<div class='icon-tint'></div>","icon-plus":"<div class='icon-plus'></div>","icon-external-link":"<div class='icon-external-link'></div>","icon-signin":"<div class='icon-signin'></div>","icon-signout":"<div class='icon-signout'></div>","icon-rss":"<div class='icon-rss'></div>","icon-wrench":"<div class='icon-wrench'></div>","icon-filter":"<div class='icon-filter'></div>","icon-link":"<div class='icon-link'></div>","icon-paper-clip":"<div class='icon-paper-clip'></div>","icon-undo":"<div class='icon-undo'></div>","icon-euro":"<div class='icon-euro'></div>","icon-slimbox":"<div class='icon-slimbox'></div>","icon-picture":"<div class='icon-picture'></div>","icon-columns":"<div class='icon-columns'></div>"}}]},contextText:{scope:{"%%":"/%"},suggest:{pfx:"%%text-(\\w*)$",match:"^default|success|info|warning|danger"},contextText:[Dialog.Selection,{cssClass:".dialog-horizontal",body:{primary:"<span class='text-primary'>primary</span>",success:"<span class='text-success'>success</span>",info:"<span class='text-info'>info</span>",warning:"<span class='text-warning'>warning</span>",danger:"<span class='text-danger'>danger</span>"}}]},contextBG:{scope:{"%%":"/%"},suggest:{pfx:"%%(default|success|info|warning|error)$",match:"^default|success|info|warning|error"},contextBG:[Dialog.Selection,{cssClass:".dialog-horizontal",body:{"default":"<span class='default'>default</span>",success:"<span class='success'>success</span>",info:"<span class='info'>info</span>",warning:"<span class='warning'>warning</span>",error:"<span class='error'>error</span>"}}]},labelDlg:{scope:{"%%":"/%"},suggest:{pfx:"%%label-(\\w*)$",match:"^default|success|info|warning|danger"},labelDlg:[Dialog.Selection,{cssClass:".dialog-horizontal",body:{"default":"<span class='label label-default'>default</span>",primary:"<span class='label label-primary'>primary</span>",success:"<span class='label label-success'>success</span>",info:"<span class='label label-info'>info</span>",warning:"<span class='label label-warning'>warning</span>",danger:"<span class='label label-danger'>danger</span>"}}]},listDlg:{scope:{"%%list-":"/%"},suggest:{pfx:"list-(?:[\\w-]+-)?(\\w*)$",match:"^\\w*"},listDlg:[Dialog.Selection,{cssClass:".dialog-horizontal",body:"nostyle|unstyled|hover|group"}]},tableDlg:{scope:{"%%table-":"/%"},suggest:{pfx:"table-(?:[\\w-]+-)?(\\w*)$",match:"^\\w*"},tableDlg:[Dialog.Selection,{cssClass:".dialog-horizontal",body:"sort|filter|striped|bordered|hover|condensed|fit"}]},cssDlg:{scope:{"%%":"/%"},suggest:{pfx:"%%([\\da-zA-Z-_]*)$",match:"^[\\da-zA-Z-_]*"},cssDlg:{"(css:value;)":"any css definitions","default":"contextual backgrounds","text-default":"contextual text color","label-default":"<span class='label label-default'>contextual labels</span>",badge:"badges <span class='badge'>13</span>",collapse:"collapsable lists","list-nostyle":"list styles","table-fit":"table styles","":"","add-css":"Add CSS",alert:"Alert Box",accordion:"Accordion",category:"Category Links",carousel:"Carousel",columns:"Multi-column layout",commentbox:"Comment Box",pills:"Pills",prettify:"Prettify syntax highlighter",scrollable:"Scrollable Preformatted block","scrollable-image":"Scrollable Wide Images",slimbox:"Slimbox Viewer <span class='icon-slimbox'></span>",tabs:"Tabs",viewer:"Media Viewer"}},link:{key:"l",commandIdentifier:"createlink",snippet:"[{pagename or url}] "},linkPart3:{suggest:{pfx:"\\[(?:[^\\|\\]]+\\|[^\\|\\]]+\\|)([^\\|\\[\\]\\n\\r]*)$",match:"^[^\\|\\]\\n\\r]*"},linkPart3:{"class='viewer'":"View Linked content","class='slimbox'":"Add Slimbox link <span class='icon-slimbox'/> ","class='slimbox-link'":"Replace by Slimbox Link <span class='icon-slimbox'/> ",divide1:"","class='btn btn-primary'":"Button Style","class='btn btn-xs btn-primary'":"Small Button Style",divide2:"","target='_blank'":"Open link in new tab"}},linkDlg:{suggest:{pfx:"\\[(?:[^\\|\\]]+\\|)?([^\\|\\[\\{\\]\\n\\r]*)$",match:"^([^\\|\\[\\{\\]\\n\\r]*)(?:\\]|\\|)"},linkDlg:[Dialog.Selection,{caption:"Wiki Link",onOpen:function(e){var t=e.getValue();if(!t||t.trim()=="")t=Wiki.PageName+"/";Wiki.jsonrpc("/search/suggestions",[t,30],function(t){t[0]?e.setBody(t):e.hide()})}}]},variableDlg:{scope:{"[{$":"}]"},suggest:"\\w+",variableDlg:"applicationname|baseurl|encoding|inlinedimages|interwikilinks|jspwikiversion|loginstatus|uptime|pagename|pageprovider|pageproviderdescription|page-styles|requestcontext|totalpages|username"},allow:{synonym:"acl"},acl:"\n[{ALLOW {permission} {principal} }]\n",permission:{scope:{"[{ALLOW":"}]"},suggest:{pfx:"ALLOW (\\w+)$",match:"^\\w+"},permission:[Dialog.Selection,{cssClass:".dialog-horizontal",body:"view|edit|modify|comment|rename|upload|delete"}]},principal:{scope:{"[{ALLOW":"}]"},suggest:{pfx:"ALLOW \\w+ (?:[\\w,]+,)?(\\w*)$",match:"^\\w*"},principal:[Dialog.Selection,{caption:"Roles, Groups or Users",onOpen:function(e){(new Request({url:Wiki.XHRPreview,data:{page:Wiki.PageName,wikimarkup:"[{Groups}]"},onSuccess:function(t){var n="Anonymous|Asserted|Authenticated|All";t=t.replace(/<[^>]+>/g,"").replace(/\s*,\s*/g,"|").trim(),t!=""&&(n=n+"||"+t),e.setBody(n)}})).send()}}]},toc:{nScope:{"[{":"}]"},snippet:"\n[\\{TableOfContents }]\n"},tocParams:{scope:{"[{TableOfContents":"}]"},suggest:"\\s",tocParams:[Dialog.Selection,{caption:"TOC additional parameters",body:{" title='Page contents' ":"title"," numbered='true' ":"numbered"," prefix='Chap. ' ":"chapter prefix"}}]},plugin:"\n[{{plugin}}]\n",pluginDlg:{suggest:{pfx:"(^|[^\\[])\\[\\{([^\\[\\]\\n\\r]*)(?:\\|\\])?$",match:"^([^\\[\\]\\n\\r]*)\\}\\]"},pluginDlg:[Dialog.Selection,{caption:"Plugin",body:{"ALLOW permission principal ":"Page Access Rights <span class='icon-unlock-alt' />","SET name='value'":"Set a Wiki variable",$varname:"Get a Wiki variable","If name='value' page='pagename' exists='true' contains='regexp'\n\nbody\n":"IF plugin","SET alias='${pagename}'":"Page Alias","SET sidebar='off'":"Collapse Sidebar","":"",Counter:"Insert a simple counter","CurrentTimePlugin format='yyyy mmm-dd'":"Insert Current Time",Denounce:"Denounce a link","Image src='${image.jpg}'":"Insert an Image <span class='icon-picture'></span>",IndexPlugin:"Index of all pages","InsertPage page='${pagename}'":"Insert another Page","SET page-styles='prettify-nonum table-condensed-fit'":"Insert Page Styles",ListLocksPlugin:"List page locks",RecentChangesPlugin:"Displays the recent changed pages","ReferredPagesPlugin page='{pagename}' type='local|external|attachment' depth='1..8' include='regexp' exclude='regexp'":"Incoming Links (referred pages)","ReferringPagesPlugin page='{pagename}' separator=',' include='regexp' exclude='regexp'":"Outgoing Links (referring pages)","Search query='Janne' max='10'":"Insert a Search query","TableOfContents ":"Table Of Contents ",UndefinedPagesPlugin:"List pages that are missing",UnusedPagesPlugin:"List pages that have been orphaned",WeblogArchivePlugin:"Displays a list of older weblog entries",WeblogEntryPlugin:"Makes a new weblog entry","WeblogPlugin page='{pagename}' startDate='300604' days='30' maxEntries='30' allowComments='false'":"Builds a weblog"}}]},selectBlock:{suggest:function(e,t,n){var r;if(!t.thin&&e.isCaretAtStartOfLine()&&e.isCaretAtEndOfLine())return console.log("got block selection"),{pfx:"xx",match:e.getSelection()}},selectBlock:[Dialog.Selection,{cssClass:".dialog-horizontal",body:{"\\{\\{\\{\n{code block}\n}}}":"<span style='font-family:monospace;'>code</span>","%%prettify\n\\{\\{\\{\n{pretiffied code block}\n}}}/%":"<span class='pun' style='font-family:monospace;'>prettify</span>"}}]},selectStartOfLine:{suggest:function(e,t,n){var r;if(!t.thin&&e.isCaretAtStartOfLine()&&!e.isCaretAtEndOfLine())return console.log("got start of line selection",t),{pfx:"xx",match:e.getSelection()}},selectStartOfLine:[Dialog.Selection,{cssClass:".dialog-horizontal",body:{"!!!{header}":"H1","!!{header}":"H2","!{header}":"H3","__{bold}__":"<b>bold</b>","''{italic}''":"<i>italic</i>","\\{\\{{monospaced text}}} ":"<tt>mono</tt>","[description|{link}|options]":"<span class='icon-link'/>","[{Image src='${image.jpg}'}]":"<span class='icon-picture'/>"}}]},selectInline:{suggest:function(e,t,n){var r;if(!t.thin)return console.log("got selection",t),{pfx:"xx",match:e.getSelection()}},selectInline:[Dialog.Selection,{cssClass:".dialog-horizontal",body:{"__{bold}__":"<b>bold</b>","''{italic}''":"<i>italic</i>","\\{\\{{monospaced text}}} ":"<tt>mono</tt>","[description|{link}|options]":"<span class='icon-link'/>","[{Image src='${image.jpg}'}]":"<span class='icon-picture'/>"}}]}},!function(e){function u(e){return t.getElement(e)}function a(){window.onbeforeunload=function(e){if(n.value!=n.defaultValue)return"edit.areyousure".localize()},t.addEvent("submit",function(){window.onbeforeunload=null})}function f(t,n,r){function a(e){n.ifClass(e,"dragging")}var s="height",o=e.prefs.get(r),u;o&&(t.setStyle(s,o),i.setStyle(s,o)),n&&t.makeResizable({handle:n,modifiers:{x:null},onDrag:function(){u=this.value.now.y,i.setStyle(s,u),e.prefs.set(r,u)},onBeforeStart:a.pass(!0),onComplete:a.pass(!1),onCancel:a.pass(!1)})}function l(){var t=r.toElement().get("value"),n="loading";console.log("**** change event",(new Date).getSeconds(),s,t.length),(u("[data-cmd=livepreview]")||{}).checked?s!=t&&(s=t,(new Request.HTML({url:e.XHRPreview,data:{page:e.PageName,wikimarkup:t},update:i,onRequest:function(){i.addClass(n)},onComplete:function(){i.removeClass(n),e.update()}})).send()):s&&(i.empty(),s=null)}function c(t){var n=u("[data-cmd="+t+"]"),s,o;n&&(s=n.checked,e.prefs.set(t,s),t.test(/livepreview|previewcolumn/)&&(o=u(".edit-area").ifClass(s,t),t=="livepreview"?u("[data-cmd=previewcolumn]").disabled=!s:(s||(o=o.getParent()),o.grab(i))),r.set(t,s).fireEvent("change"))}function h(e){var t=[],n="¤",r=e.replace(/\{\{\{([\s\S]*?)\}\}\}/g,function(e){return e.replace(/^!/mg," ")}).replace(/^([!]{1,3})/mg,n+"$1"+n).split(n),i=r.shift().length,s=r.length,o,u,a;for(o=0;o<s;o+=2)u=r[o].length,a=r[o+1].split(/[\r\n]/)[0].replace(/(^|[^~])(__|""|\{\{|\}\}|%%\([^\)]+\)|%%\S+\s|%%\([^\)]+\)|\/%)/g,"$1").replace(/~([^~])/g,"$1"),t.push({title:a,start:i,depth:3-u}),i+=u+r[o+1].length;return t}var t,n,r,i,s,o;e.add("#editform",function(s){t=s,n=u(".editor"),i=u(".ajaxpreview"),a();if(!n)return;r=new Snipe(n,{container:t,undoBtns:{undo:u("[data-cmd=undo]"),redo:u("[data-cmd=redo]")},snippets:e.Snips,directsnips:e.DirectSnips,onChange:l.debounce(500),onConfig:c}),e.Context=="edit"&&(o=u(".sections"))&&new Snipe.Sections(o,{snipe:r,parser:h}),e.resizer(r.toElement(),function(e){i.setStyle("height",e)}),t.getElements(".config [data-cmd]").each(function(t){var n=t.getAttribute("data-cmd");t.checked=!!e.prefs.get(n),t.getParent().ifClass(t.checked,"active"),c(n)})})}(Wiki)