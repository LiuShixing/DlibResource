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

<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setBundle basename="templates.default"/>
<!doctype html>
<html lang="${prefs.Language}" name="top">
  <head>
<title>错误</title>
  <wiki:Include page="commonheader.jsp"/>
  <wiki:CheckVersion mode="notlatest">
    <meta name="robots" content="noindex,nofollow" />
  </wiki:CheckVersion>
  <wiki:CheckRequestContext context="diff|info">
    <meta name="robots" content="noindex,nofollow" />
  </wiki:CheckRequestContext>
  <wiki:CheckRequestContext context="!view">
    <meta name="robots" content="noindex,follow" />
  </wiki:CheckRequestContext>
  </head>
<body class="context-<wiki:Variable var='requestcontext' default='' />">

<div class="container${prefs.Layout=='fixed' ? '' : '-fluid' } ${prefs.Orientation}">

	 <div class="header">
	
	  <div class="topline">
	
	    <div class="cage pull-left">
	    <a class="logo pull-left"
	        href="<wiki:Link page='${frontpage}' format='url' />"
	       title="资源列表 ">Dlib资源</a>
	
	    </div>
	
	    <wiki:Include page="UserBox.jsp" />
	    <wiki:Include page="SearchBox.jsp" />
	
	    <div class="pagename" title="<wiki:PageName />">
	    错误
	  <%--   <wiki:CheckRequestContext context='view'><wiki:PageName /></wiki:CheckRequestContext>
	    <wiki:CheckRequestContext context='!view'>
	      <wiki:CheckRequestContext context='viewGroup|createGroup|editGroup'><span class="icon-group"></span></wiki:CheckRequestContext>
	      <wiki:PageType type="attachment"><span class="icon-paper-clip"></span></wiki:PageType>
	      <%=title %>
	     </wiki:CheckRequestContext>  --%>
	    </div>
	
	  </div>
	 <%--  <div class="breadcrumb">
	    <fmt:message key="header.yourtrail"/><wiki:Breadcrumbs separator="<span class='divider'></span>" />
	  </div> --%>
	
	</div>
  <wiki:Include page="AAhomeNav.jsp" />

  <c:set var="sidebar"><wiki:Variable var='sidebar'  /></c:set>
  <c:set var="sidebar" value="${ (sidebar!='off') and (prefs.Orientation!='fav-hidden') ? 'on' : 'off' }" />
  <wiki:CheckRequestContext context='login|prefs|createGroup|viewGroup'>
    <c:set var="sidebar">off</c:set>
  </wiki:CheckRequestContext>

  <%--<div class="content <c:if test='${sidebar != "off"}'>active</c:if>"  --%>
  <div class="content ${sidebar != 'off' ? 'active' : '' } SIDEBAR_${prefs.Sidebar}"
        data-toggle="li#menu,.sidebar>.close"
        data-toggle-cookie="Sidebar">
    <div class="page">
 
    <%
        String error = request.getParameter("error");
        String msg="内部错误";
        
        if(error!=null)
        {
            if(error.equals("upload-error"))
              msg="上传过程出现错误，尝试重新上传?";
            if(error.equals("downLoadError"))msg="下载错误，资源可能已被删除！";
        }
     %>
    <div class="error text-align-center"><%=msg %></div>
  
      <wiki:Include page="PageInfo.jsp"/>
    </div>
    <wiki:Include page="AAsidebar.jsp"/>
  </div>
  <wiki:Include page="Footer.jsp" />

</div>

</body>
</html>