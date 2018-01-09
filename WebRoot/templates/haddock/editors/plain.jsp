<%--
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
--%>

<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.auth.permissions.*" %>
<%@ page import="org.apache.wiki.tags.*" %>
<%@ page import="org.apache.wiki.filters.SpamFilter" %>
<%@ page import="org.apache.wiki.ui.*" %>
<%@ page import="org.apache.wiki.util.TextUtil" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%--
        This is a plain editor for JSPWiki.
--%>
<%
   WikiContext context = WikiContext.findContext( pageContext );
   WikiEngine engine = context.getEngine();

   String usertext = EditorManager.getEditedText( pageContext );
   
   String pageNameString = request.getParameter("page");
%>
<wiki:RequestResource type="script" resource="scripts/haddock-edit.js" />

<wiki:CheckRequestContext context="edit">
<wiki:NoSuchPage> <%-- this is a new page, check if we're cloning --%>
<%
  String clone = request.getParameter( "clone" );
  if( clone != null )
  {
    WikiPage p = engine.getPage( clone );
    if( p != null )
    {
        AuthorizationManager mgr = engine.getAuthorizationManager();
        PagePermission pp = new PagePermission( p, PagePermission.VIEW_ACTION );

        try
        {
          if( mgr.checkPermission( context.getWikiSession(), pp ) )
          {
            usertext = engine.getPureText( p );
          }
        }
        catch( Exception e ) {  /*log.error( "Accessing clone page "+clone, e );*/ }
    }
  }
%>
</wiki:NoSuchPage>
<%
  if( usertext == null )
  {
    usertext = engine.getPureText( context.getPage() );
  }
  
 
%>
</wiki:CheckRequestContext>
<% if( usertext == null ) usertext = "";  %>

<%-- <div style="width:100%"> <%-- Required for IE6 on Windows --%>
<%
   boolean isCreateNew = false;

   String path = request.getContextPath();
   String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
 %>
 
 
<wiki:PageExists>
 <div class="accordion-close">
	<h4>页面图片：</h4>
	 <form action="<wiki:Link jsp='attach' format='url' absolute='true'><wiki:Param name='progressid' value='${progressId}'/></wiki:Link>"
	         class="accordion"
	            id="uploadform"
	        method="post"
	       enctype="multipart/form-data" accept-charset="<wiki:ContentEncoding/>" >
	
	    <h4>上传图片</h4>
	    <input type="hidden" name="nextpage" value="Edit.jsp?page=<%=pageNameString %>" />
	    <input type="hidden" name="page" value="<wiki:Variable var="pagename"/>" />
	    <input type="hidden" name="action" value="upload" />
	
	    <wiki:Messages div="alert alert-danger" />
	
	    <%-- <p><fmt:message key="attach.add.info" /></p> --%>
	    <div class="form-group">
	      <label class="control-label form-col-20" for="files">选择图片</label>
	
	      <ul class="list-group form-col-50">
	        <li class="list-group-item droppable">
	          <a class="hidden delete btn btn-danger btn-xs pull-right">Delete</a>
	          <label>选择图片 <span class='canDragAndDrop'>or drop them here!</span></label>
	          <input type="file" name="files" id="files" size="60" accept=".jpg" multiple="multiple"/>
	        </li>
	      </ul>
	    </div>
	    <div class="form-group">
	      <label class="control-label form-col-20" for="changenote"><fmt:message key="attach.add.changenote"/></label>
	      <input class="form-control form-col-50" type="text" name="changenote" id="changenote" maxlength="80" size="60" />
	    </div>
	    <div class="form-group">
	      <input class="btn btn-primary form-col-offset-20 form-col-50"
	             type="submit" name="upload" id="upload" disabled="disabled" value="<fmt:message key='attach.add.submit'/>" />
	    </div>
	    <div class="hidden form-col-offset-20 form-col-50 progress progress-striped active">
	      <div class="progress-bar" data-progressid="${progressId}" style="width: 100%;"></div>
	    </div>
	
	  </form>
	 
	 
	 <wiki:HasAttachments>
	
		  
		  <wiki:Permission permission="edit">
		    <%-- hidden delete form --%>
		    <form action="tbd"
		           class="hidden"
		            name="deleteForm" id="deleteForm"
		          method="post" accept-charset="<wiki:ContentEncoding />" >
		
		      <%--TODO: "nextpage" is not yet implemented in Delete.jsp
		      --%>
		      <input type="hidden" name="nextpage" value="<wiki:Link context='upload' format='url'/>" />
		      <input id="delete-all" name="delete-all" type="submit"
		        data-modal="+ .modal"
		             value="Delete" />
		      <div class="modal">确认删除此图片？</div>
		
		    </form>
		  </wiki:Permission>
		
		  <div class="slimbox-attachments table-filter-striped-sort-condensed">
		  <table class="table">
		    <tr>
		      <th><fmt:message key="info.attachment.type"/></th>
		      <th>图片名称</th>
		      <th>版本</th>
		      <th><fmt:message key="info.size"/></th>
		      <th><fmt:message key="info.date"/></th>
		      <th><fmt:message key="info.author"/></th>
		      <th><fmt:message key="info.actions"/></th>
		      <th><fmt:message key="info.changenote"/></th>
		    </tr>
		
		    <wiki:AttachmentsIterator id="att">
		    <tr>
		
		      <%-- see styles/fontjspwiki/icon.less : icon-file-<....>-o  --%>
		      <c:set var="parts" value="${fn:split(att.fileName, '.')}" />
		      <c:set var="type" value="${ fn:length(parts)>1 ? parts[fn:length(parts)-1] : ''}" />
		
		      <td class="attach-type"><span class="icon-file-${type}-o">${type}</span></td>
		
		      <td class="attach-name" title="${att.fileName}">${att.fileName}</td>
		
		      <td><wiki:LinkTo><wiki:PageVersion /></wiki:LinkTo></td>
		      <td class="nowrap" title="${att.size} bytes">
		        
		        <%= org.apache.commons.io.FileUtils.byteCountToDisplaySize( att.getSize() ) %>
		      </td>
		
		      <td class="nowrap" jspwiki:sortvalue="${att.lastModified.time}">
		        <fmt:formatDate value="${att.lastModified}" pattern="${prefs.DateFormat}" timeZone="${prefs.TimeZone}" />
		      </td>
		
		      <td><wiki:Author /></td>
		
		      <td class="nowrap">
		
		        <wiki:Permission permission="edit">
		          <input type="button"
		                class="btn btn-danger btn-xs"
		                value="<fmt:message key='attach.delete'/>"
		                  src="<wiki:Link format='url' context='<%=WikiContext.DELETE%>' ><wiki:Param name='tab' value='attach' /></wiki:Link>"
		              onclick="document.deleteForm.action=this.src; document.deleteForm['delete-all'].click();" />
		        </wiki:Permission>
		      </td>
		
		      <c:set var="changenote" value="<%= (String)att.getAttribute( WikiPage.CHANGENOTE ) %>" />
		      <td class="changenote">${changenote}</td>
		
		    </tr>
		    </wiki:AttachmentsIterator>
		
		  </table> 
		   </div>
		   
	   
	  </wiki:HasAttachments>
	 
	 
</div>
</wiki:PageExists>






<form method="post" accept-charset="<wiki:ContentEncoding/>"
      action="<wiki:CheckRequestContext
     context='edit'><wiki:EditLink format='url'/></wiki:CheckRequestContext><wiki:CheckRequestContext
     context='comment'><wiki:CommentLink format='url'/></wiki:CheckRequestContext>"
      

     <%--action="<wiki:Link context=${context} format='url'/>"--%>

       class="editform"
          id="editform"
     enctype="application/x-www-form-urlencoded" >


 <%@ include file="article_ifo.jsp"%> 
 
 
 
 
  <%-- Edit.jsp relies on these being found.  So be careful, if you make changes. --%>
  <input type="hidden" name="page" value="<wiki:Variable var='pagename' />" />
  <input type="hidden" name="action" value="save" />
  <%=SpamFilter.insertInputFields( pageContext )%>
  <input type="hidden" name="<%=SpamFilter.getHashFieldName(request)%>" value="${lastchange}" />
  <%-- This following field is only for the SpamFilter to catch bots which are just randomly filling all fields and submitting.
       Normal user should never see this field, nor type anything in it. --%>
  <input class="hidden" type="text" name="<%=SpamFilter.getBotFieldName()%>" id="<%=SpamFilter.getBotFieldName()%>" value="" />


  <div class="snipe">
  <div class="form-inline form-group">

  <span class="cage">
    <input class="btn btn-primary" type="submit" name="ok" accesskey="s" id="editor_submit"
           value="<fmt:message key='editor.plain.save.submit'/>" />

      <wiki:CheckRequestContext context="edit">
      <input class="form-control" data-hover-parent="span" type="text" size="80" maxlength="80"
             name="changenote" id="changenote"
             placeholder="<fmt:message key='editor.plain.changenote'/>"
             value="${changenote}" />
      </wiki:CheckRequestContext>
  </span>

  <div class="btn-group editor-tools">

    <div class="btn-group sections">
      <button class="btn btn-default"><span class="icon-bookmark"><span class="caret"></span></button>
      <ul class="dropdown-menu" data-hover-parent="div">
            <li><a>first</a></li>
            <li><a>..</a></li>
            <li><a class="dropdown-divider">..</a></li>
            <li><a>..</a></li>
      </ul>
    </div>

    <div class="btn-group formatting-options">
      <button class="btn btn-default"><span class="icon-tint" /><span class="caret" /></button>
      <ul class="dropdown-menu dropdown-menu-horizontal" data-hover-parent="div">
        <li><a href="#" data-cmd="bold" title="<fmt:message key='editor.plain.tbB.title' />"><b>bold</b></a></li>
        <li><a href="#" data-cmd="italic" title="<fmt:message key='editor.plain.tbI.title' />"><i>italic</i></a></li>
        <li><a href="#" data-cmd="mono" title="<fmt:message key='editor.plain.tbMONO.title' />"><tt>mono</tt></a></li>
        <li><a href="#" data-cmd="sub" title="<fmt:message key='editor.plain.tbSUB.title' />">a<span class="sub">sub</span></a></li>
        <li><a href="#" data-cmd="sup" title="<fmt:message key='editor.plain.tbSUP.title' />">a<span class="sup">sup</span></a></li>
        <li><a href="#" data-cmd="strike" title="<fmt:message key='editor.plain.tbSTRIKE.title' />"><span class="strike">strike</span></a></li>
        <li><a href="#" data-cmd="link" title="<fmt:message key='editor.plain.tbLink.title'/>"><span class="icon-link"/></a></li>
        <li><a href="#" data-cmd="img" title="<fmt:message key='editor.plain.tbIMG.title'/>"><span class="icon-picture"/></a></li>
        <li><a href="#" data-cmd="plugin" title="<fmt:message key='editor.plain.tbPLUGIN.title'/>"><span class="icon-puzzle-piece"/></a></li>
        <li><a href="#" data-cmd="font" title="<fmt:message key='editor.plain.tbFONT.title' />">Font<span class="caret" /></a></li>
        <li><a href="#" data-cmd="chars" title="<fmt:message key='editor.plain.tbCHARS.title' />"><span class="icon-euro"/><span class="caret" /></a></li>

       </ul>
     </div>


    <fmt:message key='editor.plain.undo.title' var='msg'/>
    <button class="btn btn-default" data-cmd="undo" title="${msg}"><span class="icon-undo"></span></button>
    <fmt:message key='editor.plain.redo.title' var='msg'/>
    <button class="btn btn-default" data-cmd="redo" title="${msg}"><span class="icon-repeat"></span></button>
    <button class="btn btn-default" data-cmd="find"><span class="icon-search" /></button>

    <div class="btn-group config">
      <%-- note: 'dropdown-toggle' is only here to style the last button properly! --%>
      <button class="btn btn-default"><span class="icon-wrench"></span><span class="caret"></span></button>
      <ul class="dropdown-menu" data-hover-parent="div">
            <li>
              <a>
                <label for="autosuggest">
                  <input type="checkbox" data-cmd="autosuggest" id="autosuggest" />
                  <fmt:message key='editor.plain.autosuggest'/>
                </label>
              </a>
            </li>
            <li>
              <a>
                <label for="tabcompletion">
                  <input type="checkbox" data-cmd="tabcompletion" id="tabcompletion" />
                  <fmt:message key='editor.plain.tabcompletion'/>
                </label>
              </a>
            </li>
            <li>
              <a>
                <label for="smartpairs">
                  <input type="checkbox" data-cmd="smartpairs" id="smartpairs" />
                  <fmt:message key='editor.plain.smartpairs'/>
                </label>
              </a>
            </li>
           <%--  <li class="divider"></li>
            <li>
              <a>
                <label for="livepreview">
                  <input type="checkbox" data-cmd="livepreview" id="livepreview"/>
                  <fmt:message key='editor.plain.livepreview'/> <span class="icon-refresh"/>
                </label>
              </a>
            </li>
            <li>
              <a>
                <label for="previewcolumn">
                  <input type="checkbox" data-cmd="previewcolumn" id="previewcolumn" />
                  <fmt:message key='editor.plain.sidebysidepreview'/> <span class="icon-columns"/>
                </label>
              </a>
            </li> --%>

      </ul>
    </div>

    <c:set var="editors" value="<%= context.getEngine().getEditorManager().getEditorList() %>" />
    <c:if test='${fn:length(editors)>1}'>
   <div class="btn-group config">
      <%-- note: 'dropdown-toggle' is only here to style the last button properly! --%>
      <button class="btn btn-default"><span class="icon-pencil"></span><span class="caret"></span></button>
      <ul class="dropdown-menu" data-hover-parent="div">
        <c:forEach items="${editors}" var="edt">
          <c:choose>
            <c:when test="${edt != prefs.editor}">
              <li>
                <wiki:Link context="edit"><wiki:Param name="editor" value="${edt}" />${edt}</wiki:Link>
              </li>
            </c:when>
            <c:otherwise>
              <li class="dropdown-header">${edt}</li>
            </c:otherwise>
          </c:choose>
      </c:forEach>
      </ul>
    </div>
    </c:if>
    

  </div>

      <div class="dialog float find">
        <div class="caption"><fmt:message key='editor.plain.find'/> &amp; <fmt:message key='editor.plain.replace'/> </div>
        <div class="body">
        <a class="close">&times;</a>
        <div class="form-group">
          <span class="tbHITS"></span>
          <input class="form-control" type="text" name="tbFIND" size="16"
                 placeholder="<fmt:message key='editor.plain.find'/>" />
        </div>
        <div class="form-group">
          <input class="form-control" type="text" name="tbREPLACE" size="16"
                 placeholder="<fmt:message key='editor.plain.replace'/>" />
        </div>
        <div class="btn-group">
          <button class="btn btn-primary" type="button" name="replace">
            <fmt:message key='editor.plain.find.submit' />
          </button>
          <button class="btn btn-primary" type="button" name="replaceall">
            <fmt:message key='editor.plain.global'/>
          </button>
          <label class="btn btn-default" for="tbMatchCASE">
            <input type="checkbox" name="tbMatchCASE" id="tbMatchCASE"/>
            <fmt:message key="editor.plain.matchcase"/>
          </label>
          <label class="btn btn-default" for="tbREGEXP">
            <input type="checkbox" name="tbREGEXP" id="tbREGEXP"/>
            <fmt:message key="editor.plain.regexp"/>
          </label>
        </div>
        </div>
      </div>


  <%-- is PREVIEW functionality still needed - with livepreview ?
  <input class="btn btn-primary" type="submit" name="preview" accesskey="v"
         value="<fmt:message key='editor.plain.preview.submit'/>"
         title="<fmt:message key='editor.plain.preview.title'/>" />
  --%>
  
				 
  <input class="btn btn-danger pull-right" type="submit" name="cancel" accesskey="q"
     value="<fmt:message key='editor.plain.cancel.submit'/>"
     title="<fmt:message key='editor.plain.cancel.title'/>" />
 

  <%--TODO: allow page rename as part of an edit session
    <wiki:Permission permission="rename">
    <div class="form-group form-inline">
    <label for="renameto"><fmt:message key='editor.renameto'/></label>
    <input type="text" name="renameto" value="<wiki:Variable var='pagename' />" size="40" />
    <input type="checkbox" name="references" checked="checked" />
    <fmt:message key="info.updatereferrers"/>
    </div>
    </wiki:Permission>
  --%>

  </div>

  <wiki:CheckRequestContext context="comment">
    <div class="info">
    <label><fmt:message key="editor.commentsignature"/></label>
    <input class="form-control form-col-20" type="text" name="author" id="authorname"
           placeholder="<fmt:message key='editor.plain.name'/>"
           value="${author}" />
    <label class="btn btn-default btn-sm" for="rememberme">
      <input type="checkbox" name="remember" id="rememberme"
             <%=TextUtil.isPositive((String)session.getAttribute("remember")) ? "checked='checked'" : ""%> />
      <fmt:message key="editor.plain.remember"/>
    </label>
   <%--  <input class="form-control form-col-20" type="text" name="link" id="link" size="24"
           placeholder="<fmt:message key='editor.plain.email'/>"
           value="${link}" /> --%>
    </div>
  </wiki:CheckRequestContext>



    <div class="row edit-area"><%-- .livepreview  .previewcolumn--%>
      <div class="col-50">
        <textarea class="editor form-control" id="editorarea" name="<%=EditorManager.REQ_EDITEDTEXT%>"
              autofocus="autofocus"
                   rows="20" cols="80"><%= TextUtil.replaceEntities(usertext) %></textarea>
      </div>
      <div class="ajaxpreview col-50" id="preText"> 
      </div>
    </div>

    <div class="resizer"
          data-resize-cookie="editorHeight"
         title="<fmt:message key='editor.plain.edit.resize'/>"></div>

  </div><%-- end of .snipe --%>

</form>

<%-- </div>   ??CHECK: needed of IEx--%>