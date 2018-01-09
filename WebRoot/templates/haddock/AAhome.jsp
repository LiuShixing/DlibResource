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

  <title>
    Dlib资源
  </title>
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
  
  <script type="text/javascript">
		

</script>
</head>

<body class="context-<wiki:Variable var='requestcontext' default='' />">

<div class="container${prefs.Layout=='fixed' ? '' : '-fluid' } ${prefs.Orientation}">

  <wiki:Include page="AAhomeHeader.jsp" />
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
      
	       String tag = request.getParameter("tag");
	       
	       if(tag!=null && tag.equals("upload"))
	       {
	     %>
	     <%@ include file="AAupload.jsp"%> 
              
       
         <%
           }else if(tag!=null && tag.equals("article"))
          {
           %>
             
              <%@ include file="AAarticle.jsp"%>
          <%
          }else if(tag != null && tag.equals("papers"))
          {    
          %>
          		<%@ include file="AApapers.jsp" %>
          		
         <%
         }else if(tag != null && tag.equals("viewpaper"))
         { 
         %>
         		<%@ include file="AAviewPaper.jsp" %>
         <%
         }else
           {
               
           %>
           
             <wiki:UserCheck status="authenticated">
           <%@ include file="AAresourceList.jsp"%>
           </wiki:UserCheck>
           
           <wiki:UserCheck status="notAuthenticated">
	  		<wiki:Permission permission="login">
	  		 <a href="<wiki:Link jsp='Login.jsp' format='url'><wiki:Param 
		         name='redirect' value="登陆"/></wiki:Link>" 
		        class="action login"
		        title="登陆以查看资源">
			需要登陆
			</a>
		</wiki:Permission>
		</wiki:UserCheck>
           
           <%
           }
            %>
           
     <%--  <wiki:Content/> --%>
      <wiki:Include page="PageInfo.jsp"/>
    </div>
    <wiki:Include page="AAsidebar.jsp"/>
  </div>
  <wiki:Include page="Footer.jsp" />

</div>

</body>
</html>