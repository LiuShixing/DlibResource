(function(){var e=/^(H[1-6]|HR|P|DIV|ADDRESS|PRE|FORM|TABLE|LI|OL|UL|TD|CAPTION|BLOCKQUOTE|CENTER|DL|DT|DD|SCRIPT|NOSCRIPT|STYLE)$/i,t=/^(https?|ftp|rmtp|mms):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i,n=/<(script|noscript|style)[\u0000-\uFFFF]*?<\/(script|noscript|style)>/g;this.MooEditable=new Class({Implements:[Events,Options],options:{toolbar:!0,cleanup:!0,paragraphise:!0,xhtml:!0,semantics:!0,actions:"bold italic underline strikethrough | insertunorderedlist insertorderedlist indent outdent | undo redo | createlink unlink | urlimage | toggleview",handleSubmit:!0,handleLabel:!0,disabled:!1,baseCSS:"html{ height: 100%; cursor: text; } body{ font-family: sans-serif; }",extraCSS:"",externalCSS:"",html:'<!DOCTYPE html><html><head><meta charset="UTF-8">{BASEHREF}<style>{BASECSS} {EXTRACSS}</style>{EXTERNALCSS}</head><body></body></html>',rootElement:"p",baseURL:"",dimensions:null},initialize:function(e,t){if(!("contentEditable"in document.body||"designMode"in document))return;this.setOptions(t),this.textarea=document.id(e),this.textarea.store("MooEditable",this),this.actions=this.options.actions.clean().split(" "),this.keys={},this.dialogs={},this.protectedElements=[],this.actions.each(function(e){var t=MooEditable.Actions[e];if(!t)return;if(t.options){var n=t.options.shortcut;n&&(this.keys[n]=e)}t.dialogs&&Object.each(t.dialogs,function(t,n){t=t.attempt(this),t.name=e+":"+n,typeOf(this.dialogs[e])!="object"&&(this.dialogs[e]={}),this.dialogs[e][n]=t},this),t.events&&Object.each(t.events,function(e,t){this.addEvent(t,e)},this)}.bind(this)),this.render()},toElement:function(){return this.textarea},render:function(){var e=this,t=this.options.dimensions||this.textarea.getSize();this.container=new Element("div",{id:this.textarea.id?this.textarea.id+"-mooeditable-container":null,"class":"mooeditable-container",styles:{width:t.x}}),this.textarea.addClass("mooeditable-textarea").setStyle("height",t.y),this.iframe=new IFrame({"class":"mooeditable-iframe",frameBorder:0,src:'javascript:""',styles:{height:t.y}}),this.toolbar=new MooEditable.UI.Toolbar({onItemAction:function(){var t=Array.from(arguments),n=t[0];e.action(n.name,t)}}),this.attach.delay(1,this),this.options.handleLabel&&this.textarea.id&&$$('label[for="'+this.textarea.id+'"]').addEvent("click",function(t){if(e.mode!="iframe")return;t.preventDefault(),e.focus()}),this.options.handleSubmit&&(this.form=this.textarea.getParent("form"),this.form&&this.form.addEvent("submit",function(){e.mode=="iframe"&&e.saveContent()})),this.fireEvent("render",this)},attach:function(){var e=this;this.mode="iframe",this.editorDisabled=!1,this.container.wraps(this.textarea),this.textarea.setStyle("display","none"),this.iframe.setStyle("display","").inject(this.textarea,"before"),Object.each(this.dialogs,function(t,n){Object.each(t,function(t){document.id(t).inject(e.iframe,"before");var r;t.addEvents({open:function(){r=e.selection.getRange(),e.editorDisabled=!0,e.toolbar.disable(n),e.fireEvent("dialogOpen",this)},close:function(){e.toolbar.enable(),e.editorDisabled=!1,e.focus(),r&&e.selection.setRange(r),e.fireEvent("dialogClose",this)}})})}),this.win=this.iframe.contentWindow,this.doc=this.win.document,Browser.firefox&&(this.doc.designMode="On");var t=this.options.html.substitute({BASECSS:this.options.baseCSS,EXTRACSS:this.options.extraCSS,EXTERNALCSS:this.options.externalCSS?'<link rel="stylesheet" type="text/css" media="screen" href="'+this.options.externalCSS+'" />':"",BASEHREF:this.options.baseURL?'<base href="'+this.options.baseURL+'" />':""});this.doc.open(),this.doc.write(t),this.doc.close(),Browser.ie?this.doc.body.contentEditable=!0:this.doc.designMode="On",Object.append(this.win,new Window),Object.append(this.doc,new Document);if(Browser.Element){var n=this.win.Element.prototype;for(var r in Element)r.test(/^[A-Z]|\$|prototype|mooEditable/)||(n[r]=Element.prototype[r])}else document.id(this.doc.body);this.setContent(this.textarea.get("value")),this.doc.addEvents({mouseup:this.editorMouseUp.bind(this),mousedown:this.editorMouseDown.bind(this),mouseover:this.editorMouseOver.bind(this),mouseout:this.editorMouseOut.bind(this),mouseenter:this.editorMouseEnter.bind(this),mouseleave:this.editorMouseLeave.bind(this),contextmenu:this.editorContextMenu.bind(this),click:this.editorClick.bind(this),dblclick:this.editorDoubleClick.bind(this),keypress:this.editorKeyPress.bind(this),keyup:this.editorKeyUp.bind(this),keydown:this.editorKeyDown.bind(this),focus:this.editorFocus.bind(this),blur:this.editorBlur.bind(this)}),this.win.addEvents({focus:this.editorFocus.bind(this),blur:this.editorBlur.bind(this)}),["cut","copy","paste"].each(function(t){e.doc.body.addListener(t,e["editor"+t.capitalize()].bind(e))}),this.textarea.addEvent("keypress",this.textarea.retrieve("mooeditable:textareaKeyListener",this.keyListener.bind(this))),Browser.firefox2&&this.doc.addEvent("focus",function(){e.win.fireEvent("focus").focus()}),this.doc.addEventListener&&this.doc.addEventListener("focus",function(){e.win.fireEvent("focus")},!0);if(!Browser.ie&&!Browser.opera){var i=function(){e.execute("styleWithCSS",!1,!1),e.doc.removeEvent("focus",i)};this.win.addEvent("focus",i)}return this.options.toolbar&&(document.id(this.toolbar).inject(this.container,"top"),this.toolbar.render(this.actions)),this.options.disabled&&this.disable(),this.selection=new MooEditable.Selection(this.win),this.oldContent=this.getContent(),this.fireEvent("attach",this),this},detach:function(){return this.saveContent(),this.textarea.setStyle("display","").removeClass("mooeditable-textarea").inject(this.container,"before"),this.textarea.removeEvent("keypress",this.textarea.retrieve("mooeditable:textareaKeyListener")),this.container.dispose(),this.fireEvent("detach",this),this},enable:function(){return this.editorDisabled=!1,this.toolbar.enable(),this},disable:function(){return this.editorDisabled=!0,this.toolbar.disable(),this},editorFocus:function(e){this.oldContent="",this.fireEvent("editorFocus",[e,this])},editorBlur:function(e){this.oldContent=this.saveContent().getContent(),this.fireEvent("editorBlur",[e,this])},editorMouseUp:function(e){if(this.editorDisabled){e.stop();return}this.options.toolbar&&this.checkStates(),this.fireEvent("editorMouseUp",[e,this])},editorMouseDown:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorMouseDown",[e,this])},editorMouseOver:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorMouseOver",[e,this])},editorMouseOut:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorMouseOut",[e,this])},editorMouseEnter:function(e){if(this.editorDisabled){e.stop();return}this.oldContent&&this.getContent()!=this.oldContent&&(this.focus(),this.fireEvent("editorPaste",[e,this])),this.fireEvent("editorMouseEnter",[e,this])},editorMouseLeave:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorMouseLeave",[e,this])},editorContextMenu:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorContextMenu",[e,this])},editorClick:function(e){if(Browser.safari||Browser.chrome){var t=e.target;Element.get(t,"tag")=="img"&&(this.options.baseURL&&t.getProperty("src").indexOf("http://")==-1&&t.setProperty("src",this.options.baseURL+t.getProperty("src")),this.selection.selectNode(t),this.checkStates())}this.fireEvent("editorClick",[e,this])},editorDoubleClick:function(e){this.fireEvent("editorDoubleClick",[e,this])},editorKeyPress:function(e){if(this.editorDisabled){e.stop();return}this.keyListener(e),this.fireEvent("editorKeyPress",[e,this])},editorKeyUp:function(e){if(this.editorDisabled){e.stop();return}var t=e.code;this.options.toolbar&&(/^enter|left|up|right|down|delete|backspace$/i.test(e.key)||t>=33&&t<=36||t==45||e.meta||e.control)&&(Browser.ie6?(clearTimeout(this.checkStatesDelay),this.checkStatesDelay=this.checkStates.delay(500,this)):this.checkStates()),this.fireEvent("editorKeyUp",[e,this])},editorKeyDown:function(t){if(this.editorDisabled){t.stop();return}if(t.key=="enter")if(this.options.paragraphise){if(t.shift&&(Browser.safari||Browser.chrome)){var n=this.selection,r=n.getRange(),i=this.doc.createElement("br");r.insertNode(i),r.setStartAfter(i),r.setEndAfter(i),n.setRange(r);if(n.getSelection().focusNode==i.previousSibling){var s=this.doc.createTextNode(" "),o=i.parentNode,u=i.nextSibling;u?o.insertBefore(s,u):o.appendChild(s),n.selectNode(s),n.collapse(1)}this.win.scrollTo(0,Element.getOffsets(n.getRange().startContainer).y),t.preventDefault()}else if(Browser.firefox||Browser.safari||Browser.chrome){var a=this.selection.getNode(),f=Element.getParents(a).include(a).some(function(t){return t.nodeName.test(e)});f||this.execute("insertparagraph")}}else if(Browser.ie){var r=this.selection.getRange(),a=this.selection.getNode();r&&a.get("tag")!="li"&&(this.selection.insertContent("<br>"),this.selection.collapse(!1)),t.preventDefault()}if(Browser.opera){var l=t.control||t.meta;l&&t.key=="x"?this.fireEvent("editorCut",[t,this]):l&&t.key=="c"?this.fireEvent("editorCopy",[t,this]):(l&&t.key=="v"||t.shift&&t.code==45)&&this.fireEvent("editorPaste",[t,this])}this.fireEvent("editorKeyDown",[t,this])},editorCut:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorCut",[e,this])},editorCopy:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorCopy",[e,this])},editorPaste:function(e){if(this.editorDisabled){e.stop();return}this.fireEvent("editorPaste",[e,this])},keyListener:function(e){var t=Browser.platform=="mac"?e.meta:e.control;if(!t||!this.keys[e.key])return;e.preventDefault();var n=this.toolbar.getItem(this.keys[e.key]);n.action(e)},focus:function(){return(this.mode=="iframe"?this.win:this.textarea).focus(),this.fireEvent("focus",this),this},action:function(e,t){var n=MooEditable.Actions[e];n.command&&typeOf(n.command)=="function"?n.command.apply(this,t):(this.focus(),this.execute(e,!1,t),this.mode=="iframe"&&this.checkStates())},execute:function(e,t,n){if(this.busy)return;return this.busy=!0,this.doc.execCommand(e,t,n),this.saveContent(),this.busy=!1,!1},toggleView:function(){return this.fireEvent("beforeToggleView",this),this.mode=="textarea"?(this.mode="iframe",this.iframe.setStyle("display",""),this.setContent(this.textarea.value),this.textarea.setStyle("display","none")):(this.saveContent(),this.mode="textarea",this.textarea.setStyle("display",""),this.iframe.setStyle("display","none")),this.fireEvent("toggleView",this),this.focus.delay(10,this),this},getContent:function(){var e=this.protectedElements,t=this.doc.body.get("html").replace(/<!-- mooeditable:protect:([0-9]+) -->/g,function(t,n){return e[n.toInt()]});return this.cleanup(this.ensureRootElement(t))},setContent:function(e){var t=this.protectedElements;return e=e.replace(n,function(e){return t.push(e),"<!-- mooeditable:protect:"+(t.length-1)+" -->"}),this.doc.body.set("html",this.ensureRootElement(e)),this},saveContent:function(){return this.mode=="iframe"&&this.textarea.set("value",this.getContent()),this.fireEvent("change"),this},ensureRootElement:function(t){if(this.options.rootElement){var n=new Element("div",{html:t.trim()}),r=-1,i=!1,s="",o=n.childNodes.length;for(var u=0;u<o;u++){var a=n.childNodes[u],f=a.nodeName;!f.test(e)&&f!=="#comment"?f==="#text"?a.nodeValue.trim()&&(r<0&&(r=u),s+=a.nodeValue):(r<0&&(r=u),s+=(new Element("div")).adopt($(a).clone()).get("html")):i=!0,u==o-1&&(i=!0);if(r>=0&&i){var l=new Element(this.options.rootElement,{html:s});n.replaceChild(l,n.childNodes[r]);for(var c=r+1;c<u;c++)n.removeChild(n.childNodes[c]),o--,u--,c--;r=-1,i=!1,s=""}}t=n.get("html").replace(/\n\n/g,"")}return t},checkStates:function(){var t=this.selection.getNode();if(!t)return;if(typeOf(t)!="element")return;this.actions.each(function(n){var r=this.toolbar.getItem(n);if(!r)return;r.deactivate();var i=MooEditable.Actions[n].states;if(!i)return;if(typeOf(i)=="function"){i.attempt([document.id(t),r],this);return}try{if(this.doc.queryCommandState(n)){r.activate();return}}catch(s){}if(i.tags){var o=t;do{var u=o.tagName.toLowerCase();if(i.tags.contains(u)){r.activate(u);break}}while((o=Element.getParent(o))!=null)}if(i.css){var o=t;do{var a=!1;for(var f in i.css){var l=i.css[f];o.style[f.camelCase()].contains(l)&&(r.activate(l),a=!0)}if(a||o.tagName.test(e))break}while((o=Element.getParent(o))!=null)}}.bind(this))},cleanup:function(e){if(!this.options.cleanup)return e.trim();do{var t=e;this.options.baseURL&&(e=e.replace('="'+this.options.baseURL,'="')),e=e.replace(/<br class\="webkit-block-placeholder">/gi,"<br />"),e=e.replace(/<span class="Apple-style-span">(.*)<\/span>/gi,"$1"),e=e.replace(/ class="Apple-style-span"/gi,""),e=e.replace(/<span style="">/gi,""),e=e.replace(/<p>\s*<br ?\/?>\s*<\/p>/gi,"<p> </p>"),e=e.replace(/<p>(&nbsp;|\s)*<\/p>/gi,"<p> </p>"),this.options.semantics||(e=e.replace(/\s*<br ?\/?>\s*<\/p>/gi,"</p>")),this.options.xhtml&&(e=e.replace(/<br>/gi,"<br />"));if(this.options.semantics){Browser.ie&&(e=e.replace(/<li>\s*<div>(.+?)<\/div><\/li>/g,"<li>$1</li>"));if(Browser.safari||Browser.chrome)e=e.replace(/^([\w\s]+.*?)<div>/i,"<p>$1</p><div>"),e=e.replace(/<div>(.+?)<\/div>/ig,"<p>$1</p>");Browser.ie||(e=e.replace(/<p>[\s\n]*(<(?:ul|ol)>.*?<\/(?:ul|ol)>)(.*?)<\/p>/ig,"$1<p>$2</p>"),e=e.replace(/<\/(ol|ul)>\s*(?!<(?:p|ol|ul|img).*?>)((?:<[^>]*>)?\w.*)$/g,"</$1><p>$2</p>")),e=e.replace(/<br[^>]*><\/p>/g,"</p>"),e=e.replace(/<p>\s*(<img[^>]+>)\s*<\/p>/ig,"$1\n"),e=e.replace(/<p([^>]*)>(.*?)<\/p>(?!\n)/g,"<p$1>$2</p>\n"),e=e.replace(/<\/(ul|ol|p)>(?!\n)/g,"</$1>\n"),e=e.replace(/><li>/g,">\n	<li>"),e=e.replace(/([^\n])<\/(ol|ul)>/g,"$1\n</$2>"),e=e.replace(/([^\n])<img/ig,"$1\n<img"),e=e.replace(/^\s*$/g,"")}e=e.replace(/<br ?\/?>$/gi,""),e=e.replace(/^<br ?\/?>/gi,""),this.options.paragraphise&&(e=e.replace(/(h[1-6]|p|div|address|pre|li|ol|ul|blockquote|center|dl|dt|dd)><br ?\/?>/gi,"$1>")),e=e.replace(/<br ?\/?>\s*<\/(h1|h2|h3|h4|h5|h6|li|p)/gi,"</$1"),e=e.replace(/<span style="font-weight: bold;">(.*)<\/span>/gi,"<strong>$1</strong>"),e=e.replace(/<span style="font-style: italic;">(.*)<\/span>/gi,"<em>$1</em>"),e=e.replace(/<b\b[^>]*>(.*?)<\/b[^>]*>/gi,"<strong>$1</strong>"),e=e.replace(/<i\b[^>]*>(.*?)<\/i[^>]*>/gi,"<em>$1</em>"),e=e.replace(/<u\b[^>]*>(.*?)<\/u[^>]*>/gi,'<span style="text-decoration: underline;">$1</span>'),e=e.replace(/<strong><span style="font-weight: normal;">(.*)<\/span><\/strong>/gi,"$1"),e=e.replace(/<em><span style="font-weight: normal;">(.*)<\/span><\/em>/gi,"$1"),e=e.replace(/<span style="text-decoration: underline;"><span style="font-weight: normal;">(.*)<\/span><\/span>/gi,"$1"),e=e.replace(/<strong style="font-weight: normal;">(.*)<\/strong>/gi,"$1"),e=e.replace(/<em style="font-weight: normal;">(.*)<\/em>/gi,"$1"),e=e.replace(/<[^> ]*/g,function(e){return e.toLowerCase()}),e=e.replace(/<[^>]*>/g,function(e){return e=e.replace(/ [^=]+=/g,function(e){return e.toLowerCase()}),e}),e=e.replace(/<[^!][^>]*>/g,function(e){return e=e.replace(/( [^=]+=)([^"][^ >]*)/g,'$1"$2"'),e}),this.options.xhtml&&(e=e.replace(/<img([^>]+)(\s*[^\/])>(<\/img>)*/gi,"<img$1$2 />")),e=e.replace(/<p>(?:\s*)<p>/g,"<p>"),e=e.replace(/<\/p>\s*<\/p>/g,"</p>"),e=e.replace(/<pre[^>]*>.*?<\/pre>/gi,function(e){return e.replace(/<br ?\/?>/gi,"\n")}),e=e.trim()}while(e!=t);return e}}),MooEditable.Selection=new Class({initialize:function(e){this.win=e},getSelection:function(){return this.win.focus(),this.win.getSelection?this.win.getSelection():this.win.document.selection},getRange:function(){var e=this.getSelection();if(!e)return null;try{return e.rangeCount>0?e.getRangeAt(0):e.createRange?e.createRange():null}catch(t){return this.doc.body.createTextRange()}},setRange:function(e){if(e.select)Function.attempt(function(){e.select()});else{var t=this.getSelection();t.addRange&&(t.removeAllRanges(),t.addRange(e))}},selectNode:function(e,t){var n=this.getRange(),r=this.getSelection();return n.moveToElementText?Function.attempt(function(){n.moveToElementText(e),n.select()}):r.addRange?(t?n.selectNodeContents(e):n.selectNode(e),r.removeAllRanges(),r.addRange(n)):r.setBaseAndExtent(e,0,e,1),e},isCollapsed:function(){var e=this.getRange();return e.item?!1:e.boundingWidth==0||this.getSelection().isCollapsed},collapse:function(e){var t=this.getRange(),n=this.getSelection();t.select?(t.collapse(e),t.select()):e?n.collapseToStart():n.collapseToEnd()},getContent:function(){var e=this.getRange(),t=new Element("body");if(this.isCollapsed())return"";e.cloneContents?t.appendChild(e.cloneContents()):e.item!=undefined||e.htmlText!=undefined?t.set("html",e.item?e.item(0).outerHTML:e.htmlText):t.set("html",e.toString());var n=t.get("html");return n},getText:function(){var e=this.getRange(),t=this.getSelection();return this.isCollapsed()?"":e.text||(t.toString?t.toString():"")},getNode:function(){var e=this.getRange();if(!Browser.ie||Browser.version>=9){var t=null;if(e){t=e.commonAncestorContainer,e.collapsed||e.startContainer==e.endContainer&&e.startOffset-e.endOffset<2&&e.startContainer.hasChildNodes()&&(t=e.startContainer.childNodes[e.startOffset]);while(typeOf(t)!="element")t=t.parentNode}return document.id(t)}return document.id(e.item?e.item(0):e.parentElement())},insertContent:function(e){if(Browser.ie){var t=this.getRange();if(t.pasteHTML)t.pasteHTML(e),t.collapse(!1),t.select();else if(t.insertNode){t.deleteContents();if(t.createContextualFragment)t.insertNode(t.createContextualFragment(e));else{var n=this.win.document,r=n.createDocumentFragment(),i=n.createElement("div");r.appendChild(i),i.outerHTML=e,t.insertNode(r)}}}else this.win.document.execCommand("insertHTML",!1,e)}});var r={};MooEditable.Locale={define:function(e,t){if(typeOf(window.Locale)!="null")return Locale.define("en-US","MooEditable",e,t);typeOf(e)=="object"?Object.merge(r,e):r[e]=t},get:function(e){return typeOf(window.Locale)!="null"?Locale.get("MooEditable."+e):e?r[e]:""}},MooEditable.Locale.define({ok:"OK",cancel:"Cancel",bold:"Bold",italic:"Italic",underline:"Underline",strikethrough:"Strikethrough",unorderedList:"Unordered List",orderedList:"Ordered List",indent:"Indent",outdent:"Outdent",undo:"Undo",redo:"Redo",removeHyperlink:"Remove Hyperlink",addHyperlink:"Add Hyperlink",selectTextHyperlink:"Please select the text you wish to hyperlink.",enterURL:"Enter URL",enterImageURL:"Enter image URL",addImage:"Add Image",toggleView:"Toggle View"}),MooEditable.UI={},MooEditable.UI.Toolbar=new Class({Implements:[Events,Options],options:{"class":""},initialize:function(e){this.setOptions(e),this.el=new Element("div",{"class":"mooeditable-ui-toolbar "+this.options["class"]}),this.items={},this.content=null},toElement:function(){return this.el},render:function(e){return this.content?this.el.adopt(this.content):this.content=e.map(function(e){return e=="|"?this.addSeparator():e=="/"?this.addLineSeparator():this.addItem(e)}.bind(this)),this},addItem:function(e){var t=this,n=MooEditable.Actions[e];if(!n)return;var r=n.type||"button",i=n.options||{},s=new(MooEditable.UI[r.camelCase().capitalize()])(Object.append(i,{name:e,"class":e+"-item toolbar-item",title:n.title,onAction:t.itemAction.bind(t)}));return this.items[e]=s,document.id(s).inject(this.el),s},getItem:function(e){return this.items[e]},addSeparator:function(){return(new Element("span.toolbar-separator")).inject(this.el)},addLineSeparator:function(){return(new Element("div.toolbar-line-separator")).inject(this.el)},itemAction:function(){this.fireEvent("itemAction",arguments)},disable:function(e){return Object.each(this.items,function(t){t.name==e?t.activate():t.deactivate().disable()}),this},enable:function(){return Object.each(this.items,function(e){e.enable()}),this},show:function(){return this.el.setStyle("display",""),this},hide:function(){return this.el.setStyle("display","none"),this}}),MooEditable.UI.Button=new Class({Implements:[Events,Options],options:{title:"",name:"",text:"Button","class":"",shortcut:"",mode:"icon"},initialize:function(e){this.setOptions(e),this.name=this.options.name,this.render()},toElement:function(){return this.el},render:function(){var e=this,t=Browser.platform=="mac"?"Cmd":"Ctrl",n=this.options.shortcut?" ( "+t+"+"+this.options.shortcut.toUpperCase()+" )":"",r=this.options.title||name,i=r+n;return this.el=new Element("button",{"class":"mooeditable-ui-button "+e.options["class"],title:i,html:'<span class="button-icon"></span><span class="button-text">'+r+"</span>",events:{click:e.click.bind(e),mousedown:function(e){e.preventDefault()}}}),this.options.mode!="icon"&&this.el.addClass("mooeditable-ui-button-"+this.options.mode),this.active=!1,this.disabled=!1,Browser.ie&&this.el.addEvents({mouseenter:function(e){this.addClass("hover")},mouseleave:function(e){this.removeClass("hover")}}),this},click:function(e){e.preventDefault();if(this.disabled)return;this.action(e)},action:function(){this.fireEvent("action",[this].concat(Array.from(arguments)))},enable:function(){this.active&&this.el.removeClass("onActive");if(!this.disabled)return;return this.disabled=!1,this.el.removeClass("disabled").set({disabled:!1,opacity:1}),this},disable:function(){if(this.disabled)return;return this.disabled=!0,this.el.addClass("disabled").set({disabled:!0,opacity:.4}),this},activate:function(){if(this.disabled)return;return this.active=!0,this.el.addClass("onActive"),this},deactivate:function(){return this.active=!1,this.el.removeClass("onActive"),this}}),MooEditable.UI.Dialog=new Class({Implements:[Events,Options],options:{"class":"",contentClass:""},initialize:function(e,t){this.setOptions(t),this.html=e;var n=this;this.el=new Element("div",{"class":"mooeditable-ui-dialog "+n.options["class"],html:'<div class="dialog-content '+n.options.contentClass+'">'+e+"</div>",styles:{display:"none"},events:{click:n.click.bind(n)}})},toElement:function(){return this.el},click:function(){return this.fireEvent("click",arguments),this},open:function(){return this.el.setStyle("display",""),this.fireEvent("open",this),this},close:function(){return this.el.setStyle("display","none"),this.fireEvent("close",this),this}}),MooEditable.UI.AlertDialog=function(e){if(!e)return;var t=e+' <button class="dialog-ok-button">'+MooEditable.Locale.get("ok")+"</button>";return new MooEditable.UI.Dialog(t,{"class":"mooeditable-alert-dialog",onOpen:function(){var e=this.el.getElement(".dialog-ok-button");(function(){e.focus()}).delay(10)},onClick:function(e){e.preventDefault();if(e.target.tagName.toLowerCase()!="button")return;document.id(e.target).hasClass("dialog-ok-button")&&this.close()}})},MooEditable.UI.PromptDialog=function(e,t,n){if(!e)return;var r='<label class="dialog-label">'+e+' <input type="text" class="text dialog-input" value="'+t+'">'+'</label> <button class="dialog-button dialog-ok-button">'+MooEditable.Locale.get("ok")+"</button>"+'<button class="dialog-button dialog-cancel-button">'+MooEditable.Locale.get("cancel")+"</button>";return new MooEditable.UI.Dialog(r,{"class":"mooeditable-prompt-dialog",onOpen:function(){var e=this.el.getElement(".dialog-input");(function(){e.focus(),e.select()}).delay(10)},onClick:function(e){e.preventDefault();if(e.target.tagName.toLowerCase()!="button")return;var r=document.id(e.target),i=this.el.getElement(".dialog-input");if(r.hasClass("dialog-cancel-button"))i.set("value",t),this.close();else if(r.hasClass("dialog-ok-button")){var s=i.get("value");i.set("value",t),this.close(),n&&n.attempt(s,this)}}})},MooEditable.Actions={bold:{title:MooEditable.Locale.get("bold"),options:{shortcut:"b"},states:{tags:["b","strong"],css:{"font-weight":"bold"}},events:{beforeToggleView:function(){if(Browser.firefox){var e=this.textarea.get("value"),t=e.replace(/<strong([^>]*)>/gi,"<b$1>").replace(/<\/strong>/gi,"</b>");e!=t&&this.textarea.set("value",t)}},attach:function(){if(Browser.firefox){var e=this.textarea.get("value"),t=e.replace(/<strong([^>]*)>/gi,"<b$1>").replace(/<\/strong>/gi,"</b>");e!=t&&(this.textarea.set("value",t),this.setContent(t))}}}},italic:{title:MooEditable.Locale.get("italic"),options:{shortcut:"i"},states:{tags:["i","em"],css:{"font-style":"italic"}},events:{beforeToggleView:function(){if(Browser.firefox){var e=this.textarea.get("value"),t=e.replace(/<embed([^>]*)>/gi,"<tmpembed$1>").replace(/<em([^>]*)>/gi,"<i$1>").replace(/<tmpembed([^>]*)>/gi,"<embed$1>").replace(/<\/em>/gi,"</i>");e!=t&&this.textarea.set("value",t)}},attach:function(){if(Browser.firefox){var e=this.textarea.get("value"),t=e.replace(/<embed([^>]*)>/gi,"<tmpembed$1>").replace(/<em([^>]*)>/gi,"<i$1>").replace(/<tmpembed([^>]*)>/gi,"<embed$1>").replace(/<\/em>/gi,"</i>");e!=t&&(this.textarea.set("value",t),this.setContent(t))}}}},underline:{title:MooEditable.Locale.get("underline"),options:{shortcut:"u"},states:{tags:["u"],css:{"text-decoration":"underline"}},events:{beforeToggleView:function(){if(Browser.firefox||Browser.ie){var e=this.textarea.get("value"),t=e.replace(/<span style="text-decoration: underline;"([^>]*)>/gi,"<u$1>").replace(/<\/span>/gi,"</u>");e!=t&&this.textarea.set("value",t)}},attach:function(){if(Browser.firefox||Browser.ie){var e=this.textarea.get("value"),t=e.replace(/<span style="text-decoration: underline;"([^>]*)>/gi,"<u$1>").replace(/<\/span>/gi,"</u>");e!=t&&(this.textarea.set("value",t),this.setContent(t))}}}},strikethrough:{title:MooEditable.Locale.get("strikethrough"),options:{shortcut:"s"},states:{tags:["s","strike"],css:{"text-decoration":"line-through"}}},insertunorderedlist:{title:MooEditable.Locale.get("unorderedList"),states:{tags:["ul"]}},insertorderedlist:{title:MooEditable.Locale.get("orderedList"),states:{tags:["ol"]}},indent:{title:MooEditable.Locale.get("indent"),states:{tags:["blockquote"]}},outdent:{title:MooEditable.Locale.get("outdent")},undo:{title:MooEditable.Locale.get("undo"),options:{shortcut:"z"}},redo:{title:MooEditable.Locale.get("redo"),options:{shortcut:"y"}},unlink:{title:MooEditable.Locale.get("removeHyperlink")},createlink:{title:MooEditable.Locale.get("addHyperlink"),options:{shortcut:"l"},states:{tags:["a"]},dialogs:{alert:MooEditable.UI.AlertDialog.pass(MooEditable.Locale.get("selectTextHyperlink")),prompt:function(e){return MooEditable.UI.PromptDialog(MooEditable.Locale.get("enterURL"),"http://",function(t){e.execute("createlink",!1,t.trim())})}},command:function(){var e=this.selection,n=this.dialogs.createlink;if(e.isCollapsed()){var r=e.getNode();if(r.get("tag")=="a"&&r.get("href")){e.selectNode(r);var i=n.prompt;i.el.getElement(".dialog-input").set("value",r.get("href")),i.open()}else n.alert.open()}else{var s=e.getText(),i=n.prompt;t.test(s)&&i.el.getElement(".dialog-input").set("value",s),i.open()}}},urlimage:{title:MooEditable.Locale.get("addImage"),options:{shortcut:"m"},dialogs:{prompt:function(e){return MooEditable.UI.PromptDialog(MooEditable.Locale.get("enterImageURL"),"http://",function(t){e.execute("insertimage",!1,t.trim())})}},command:function(){this.dialogs.urlimage.prompt.open()}},toggleview:{title:MooEditable.Locale.get("toggleView"),command:function(){this.mode=="textarea"?this.toolbar.enable():this.toolbar.disable("toggleview"),this.toggleView()}}},MooEditable.Actions.Settings={},Element.Properties.mooeditable={get:function(){return this.retrieve("MooEditable")}},Element.implement({mooEditable:function(e){var t=this.get("mooeditable");return t||(t=new MooEditable(this,e)),t}})})(),MooEditable.UI.MenuList=new Class({Implements:[Events,Options],options:{title:"",name:"","class":"",list:[]},initialize:function(e){this.setOptions(e),this.name=this.options.name,this.render()},toElement:function(){return this.el},render:function(){var e=this,t="";return this.options.list.each(function(e){t+='<option value="{value}" style="{style}">{text}</option>'.substitute(e)}),this.el=new Element("select",{"class":e.options["class"],title:e.options.title,html:t,styles:{height:"21px"},events:{change:e.change.bind(e)}}),this.disabled=!1,Browser.ie&&this.el.addEvents({mouseenter:function(e){this.addClass("hover")},mouseleave:function(e){this.removeClass("hover")}}),this},change:function(e){e.preventDefault();if(this.disabled)return;var t=e.target.value;this.action(t)},action:function(){this.fireEvent("action",[this].concat(Array.from(arguments)))},enable:function(){if(!this.disabled)return;return this.disabled=!1,this.el.set("disabled",!1).removeClass("disabled").set({disabled:!1,opacity:1}),this},disable:function(){if(this.disabled)return;return this.disabled=!0,this.el.set("disabled",!0).addClass("disabled").set({disabled:!0,opacity:.4}),this},activate:function(e){if(this.disabled)return;var t=0;return e&&this.options.list.each(function(n,r){n.value==e&&(t=r)}),this.el.selectedIndex=t,this},deactivate:function(){return this.el.selectedIndex=0,this.el.removeClass("onActive"),this}}),MooEditable.Locale.define({blockFormatting:"Block Formatting",paragraph:"Paragraph",heading1:"Heading 1",heading2:"Heading 2",heading3:"Heading 3",heading4:"Heading 4",alignLeft:"Align Left",alignRight:"Align Right",alignCenter:"Align Center",alignJustify:"Align Justify",removeFormatting:"Remove Formatting",insertHorizontalRule:"Insert Horizontal Rule"}),Object.append(MooEditable.Actions,{formatBlock:{title:MooEditable.Locale.get("blockFormatting"),type:"menu-list",options:{list:[{text:MooEditable.Locale.get("paragraph"),value:"p"},{text:MooEditable.Locale.get("heading2"),value:"h2",style:"font-size:18px; font-weight:bold;"},{text:MooEditable.Locale.get("heading3"),value:"h3",style:"font-size:14px; font-weight:bold;"},{text:MooEditable.Locale.get("heading4"),value:"h4",style:"font-size:12px; font-weight:bold;"}]},states:{tags:["p","h1","h2","h3"]},command:function(e,t){var n="<"+t+">";this.focus(),this.execute("formatBlock",!1,n)}},justifyleft:{title:MooEditable.Locale.get("alignLeft"),states:{css:{"text-align":"left"}}},justifyright:{title:MooEditable.Locale.get("alignRight"),states:{css:{"text-align":"right"}}},justifycenter:{title:MooEditable.Locale.get("alignCenter"),states:{tags:["center"],css:{"text-align":"center"}}},justifyfull:{title:MooEditable.Locale.get("alignJustify"),states:{css:{"text-align":"justify"}}},removeformat:{title:MooEditable.Locale.get("removeFormatting")},insertHorizontalRule:{title:MooEditable.Locale.get("insertHorizontalRule"),states:{tags:["hr"]},command:function(){this.selection.insertContent("<hr>")}}})