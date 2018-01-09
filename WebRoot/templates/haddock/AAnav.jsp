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

<%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.attachment.*" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%
  WikiContext c = WikiContext.findContext( pageContext );
  
  HttpSession sess = request.getSession();
  
  ResourceInfo info=null;
  if(sess !=null)
  {
     String ID = (String)sess.getAttribute(MyUtil.REQ_RES_ID);
     if(ID!=null)
     { 
            ServletContext app = request.getServletContext();
            if(app!=null)
            {
                Map<String,ResourceInfo> mp=(Map<String,ResourceInfo>)app.getAttribute(MyUtil.RESOURCE_INFO_MP);
                if(mp!=null)
                {
                   info = mp.get(ID.toLowerCase());
                }
            }
     }  
  }
  
  
  
%>
<c:set var="attachments" value="<%= c.getEngine().getAttachmentManager().listAttachments( c.getPage() ).size() %>" />

<%-- navigation bar --%>
<div class="row sticky">

<ul class="nav nav-pills pull-left">
  <%-- toggle sidebar --%>
  <li id="menu"><a href="#"><!--&#x2261;-->&#9776;</a></li>
  
  <%
      if(info!=null)
      {
   %>
   <li class="pagename">
    <wiki:CheckRequestContext context='view'><a href="#top"><%=info.getTitle() %></a></wiki:CheckRequestContext>
    <wiki:CheckRequestContext context='!view'><wiki:Link><%=info.getTitle() %></wiki:Link></wiki:CheckRequestContext> 
  </li> 
  <% }%>
</ul>

<ul class="nav nav-pills pull-right">

  <!--  view -->
  <wiki:CheckRequestContext context='info|diff|upload|rename|edit'>
  <li id="view">
    <wiki:PageType type="page">
      <wiki:Link>
        <fmt:message key="view.tab"/>
      </wiki:Link>
    </wiki:PageType>
  </li>
  </wiki:CheckRequestContext>
  
 <%--  <%
      String pageName = request.getParameter("page");
      if(pageName!=null && pageName.equals("help"))
      {
   %>
    attachment
  <wiki:CheckRequestContext context='view|info|upload|rename|diff|rename|edit'>
  <wiki:PageExists>
  <li id="attach"
   class="<wiki:Permission permission='!upload'>disabled</wiki:Permission>">
    <c:set var="page">
      <wiki:PageType type="page"><wiki:PageName/></wiki:PageType>
      <wiki:PageType type="attachment"><wiki:ParentPageName/></wiki:PageType>
    </c:set>
    <wiki:Link page="${page}" context="upload" accessKey="a" >
      <fmt:message key='attach.tab'/>
      <c:if test="${attachments > 0}"><span class="badge">${attachments}</span></c:if>
    </wiki:Link>
  </li>
  </wiki:PageExists>
  </wiki:CheckRequestContext>
   <%
      }
    %>
   --%>

 <%
boolean is_edit=true;
String p_id=request.getParameter("page");
if(p_id==null)p_id="zanwei";
if(p_id.getBytes()[0] =='3')
{//个人主页
	WikiSession wikiSession = c.getWikiSession();
	String curr_user = wikiSession.getUserPrincipal().getName();
		
	DBManager db=new DBManager("select fullname from homepage where pageid=?");
	db.pst.setString(1, p_id);
	ResultSet rs=db.pst.executeQuery();
	String page_owner=null;
	if(rs.next())
	{
		page_owner=rs.getString(1);
	}
	rs.close();
	db.close();
	if(page_owner!=null && !page_owner.equals(curr_user))
	{
		is_edit=false;
	}
}


if(is_edit)
{
 %>
  <%-- info --%>
  <wiki:CheckRequestContext context='view|info|upload|rename|edit'>
  <wiki:PageExists>
  <li id="info">
    <wiki:Link context="info" accessKey="i">
      <fmt:message key='info.tab'/><wiki:PageExists><span class="caret"></span></wiki:PageExists>
    </wiki:Link>
    <ul class="dropdown-menu pull-right" data-hover-parent="li">
      <li class="dropdown-header">版本 <span class="badge"><wiki:PageVersion /></span></li>
      <li class="dropdown-header">修改于:</span></li>
      <wiki:CheckVersion mode="latest">
        <li><wiki:DiffLink version="latest" newVersion="previous"><wiki:PageDate format='${prefs["DateFormat"]}'/></wiki:DiffLink></li>
      </wiki:CheckVersion>
      <wiki:CheckVersion mode="notlatest">
        <li><wiki:DiffLink version="current" newVersion="latest"><wiki:PageDate format='${prefs["DateFormat"]}'/></wiki:DiffLink></li>
      </wiki:CheckVersion>
      <li class="dropdown-header">作者:</span></li>
      <li>
        <%-- wiki:Author sometimes returns a link(ok) or a plain text, we always need a link! --%>
        <c:set var="author"><wiki:Author/></c:set>
        <c:choose>
          <c:when test="${ fn:contains(author,'href=')}">${author}</c:when>
          <c:otherwise><a href="#">${author}</a></c:otherwise>
        </c:choose>
      </li>
      <li class="divider"></li>
      <li><wiki:RSSImageLink mode="wiki" /></li>
    </ul>
  </li>
  </wiki:PageExists>
  </wiki:CheckRequestContext>


  <%-- edit --%>
  <wiki:PageType type="page">
  <wiki:CheckRequestContext context='view|info|diff|upload|rename'>
	<li id="edit"
	  class="<wiki:Permission permission='!edit'>disabled</wiki:Permission>">
      <wiki:PageType type="page">
        <wiki:Link context="edit" accessKey="e" >
          <fmt:message key='actions.edit'/>
        </wiki:Link>
      </wiki:PageType>
      <wiki:PageType type="attachment">
        <wiki:Link context="edit" page="<wiki:ParentPageName />" accessKey="e" >
          <fmt:message key='actions.edit'/>
        </wiki:Link>
      </wiki:PageType>
    </li>
  </wiki:CheckRequestContext>
  </wiki:PageType>
<%
}
 %>
  <wiki:CheckRequestContext context='edit|comment'>
  <li>
    <a class="slimbox-link" href="ShowHelp.jsp?page=help">
    编辑宝典
      <%-- <fmt:message key="edit.tab.help" /> --%>
    </a> 
  </li>
  </wiki:CheckRequestContext>

  <%-- help slimbox-link --%>
 <%--  <wiki:CheckRequestContext context='find'>
  <li>
    <a class="slimbox-link" href="<wiki:Link format='url' page='SearchPageHelp' ><wiki:Param name='skin' value='reader'/></wiki:Link>">
      <fmt:message key="find.tab.help" />
    </a>
  </li>
  </wiki:CheckRequestContext>
  <wiki:CheckRequestContext context='edit|comment'>
  <li>
    <a class="slimbox-link" href="<wiki:Link format='url' page='EditPageHelp' ><wiki:Param name='skin' value='reader'/></wiki:Link>">
      <fmt:message key="edit.tab.help" />
    </a>
    
      <wiki:NoSuchPage page="EditPageHelp">
        <div class="error">
        <fmt:message key="comment.edithelpmissing">
        <fmt:param><wiki:EditLink page="EditPageHelp">EditPageHelp</wiki:EditLink></fmt:param>
        </fmt:message>
        </div>
      </wiki:NoSuchPage>
    
  </li>
  </wiki:CheckRequestContext>
  <wiki:CheckRequestContext context='login'>
  <li>
    <a class="slimbox-link" href="<wiki:Link format='url' page='LoginHelp' ><wiki:Param name='skin' value='reader'/></wiki:Link>">
      <fmt:message key="login.tab.help" />
    </a>
  </li>
  
  <wiki:NoSuchPage page="LoginHelp">
  <div class="error">
    <fmt:message key="login.loginhelpmissing">
       <fmt:param><wiki:EditLink page="LoginHelp">LoginHelp</wiki:EditLink></fmt:param>
    </fmt:message>
  </div>
  </wiki:NoSuchPage>
 
  </wiki:CheckRequestContext>
 --%>


  <%-- more menu --%>
  <li id="more">
    <a href="#"><fmt:message key="actions.more"/><span class="caret"></span></a>
    <ul class="dropdown-menu pull-right" data-hover-parent="li">
      <wiki:PageExists>
      <wiki:CheckRequestContext context='view|info|diff|upload|preview' >

        <%-- VIEW RAW PAGE SOURCE --%>
        <li>
          <wiki:CheckVersion mode="latest">
            <wiki:Link cssClass="slimbox-link">
              <wiki:Param name='skin' value='raw'/>
              <fmt:message key='actions.rawpage' />
            </wiki:Link>
          </wiki:CheckVersion>
          <wiki:CheckVersion mode="notlatest">
            <wiki:Link cssClass="slimbox-link" version='${param.version}'>
              <wiki:Param name='skin' value='raw'/>
              <fmt:message key='actions.rawpage' />
            </wiki:Link>
          </wiki:CheckVersion>
        </li>


      </wiki:CheckRequestContext>
      </wiki:PageExists>


      <%-- ADD COMMENT --%>
      <wiki:CheckRequestContext context='view|info|diff|upload'>
      <wiki:PageExists>
      <wiki:Permission permission="comment">
        <wiki:PageType type="page">
          <li>
            <wiki:Link context="comment">
              <fmt:message key="actions.comment" />
            </wiki:Link>
          </li>
        </wiki:PageType>
        <wiki:PageType type="attachment">
          <li>
            <%--
            <wiki:Link page="<wiki:ParentPageName />" context="comment" title="<fmt:message key='actions.comment.title' />">
              <fmt:message key="actions.comment" />
            </wiki:Link>
            --%>
            <wiki:LinkToParent><fmt:message key="actions.comment" /> To Parent</wiki:LinkToParent>
	      </li>
        </wiki:PageType>
      </wiki:Permission>
      </wiki:PageExists>
      </wiki:CheckRequestContext>

    

      <%-- GROUPS : moved to the UserBox.jsp
      <wiki:CheckRequestContext context='!creategroup' >
      <wiki:Permission permission="createGroups">
        <li>
          <wiki:Link jsp="NewGroup.jsp" title="<fmt:message key='actions.creategroup.title'/>" >
            <fmt:message key='actions.creategroup' />
          </wiki:Link>
        </li>
      </wiki:Permission>
      </wiki:CheckRequestContext>
      --%>

      <%-- divider --%>
      <wiki:PageExists page="MoreMenu">

        <wiki:CheckRequestContext context='view|info|diff|upload|createGroup'>
          <li class="divider "></li>
        </wiki:CheckRequestContext>
        <wiki:CheckRequestContext context='prefs|edit'>
          <wiki:UserCheck status="authenticated">
            <li class="divider "></li>
          </wiki:UserCheck>
        </wiki:CheckRequestContext>


      <li class="more-menu"><wiki:InsertPage page="MoreMenu" /></li>
      </wiki:PageExists>

    </ul>
  </li>

</ul>

</div>

<%--
  <wiki:PageExists>
  <wiki:PageType type="page">
  <wiki:Tab id="attach" title="<%= attTitle %>" accesskey="a">
    <wiki:Include page="AttachmentTab.jsp"/>
  </wiki:Tab>
  </wiki:PageType>

  </wiki:PageExists>
--%>
