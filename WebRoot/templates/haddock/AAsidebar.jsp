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
<%@page import="org.apache.wiki.auth.user.UserProfile"%>
<%@ page import="java.security.Principal" %>
<%@page import="org.apache.wiki.auth.UserManager"%>
<%@page import="org.apache.wiki.auth.AuthorizationManager"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%@ page import="org.apache.wiki.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>

<div class="sidebar">
  <%--<button class="close" type="button">&times;</button>--%>
  <wiki:UserCheck status="authenticated">
	<div class="accordion">
		<h3>资源</h3>
		<div class="mySidebarItem">	     
		         <a href="Home.jsp?tag=all">全部</a>   
		</div>
		<div class="mySidebarItem">        
		         <a href="Home.jsp?tag=deeplearning">深度学习</a>       
		</div>
		<div class="mySidebarItem">        
		          <a href="Home.jsp?tag=kg">知识图谱</a>        
		</div>
		<div class="mySidebarItem">        
		          <a href="Home.jsp?tag=med">医疗</a>        
		</div>
		<div class="mySidebarItem ">        
		          <a href="Home.jsp?tag=edu">教育</a>        
		</div>
		<div class="mySidebarItem">        
		          <a href="Home.jsp?tag=other">其他</a>        
		</div>
		<div class="mySidebarItem">        
		          <a href="Home.jsp?tag=upload">上传</a>        
		</div>
	</div>
	
	<div class="accordion">
		<h3>科研成果</h3>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=papers">论文</a>        
		</div>
    </div>
	
	<div class="accordion-close">
		<h3>文章</h3>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=article">全部</a>        
		</div>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=article&type=report">读书报告</a>        
		</div>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=article&type=other">其他</a>        
		</div>
		<div class="mySidebarItem">        
	          <a href="AddPageForArticle.jsp?tag=write">写文章</a>        
		</div>
   </div>
   
</wiki:UserCheck>

<wiki:UserCheck status="notAuthenticated">
	  <wiki:Permission permission="login">
		 <a href="<wiki:Link jsp='Login.jsp' format='url'><wiki:Param 
		         name='redirect' value="登陆"/></wiki:Link>" 
		        class="action login"
		        title="登陆以查看资源">
			<div class="accordion-close">
					<h3>资源</h3>		
			</div>
		</a>
	</wiki:Permission>
	
	<div class="accordion">
		<h3>科研成果</h3>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=papers">论文</a>        
		</div>
   </div>
	
	<div class="accordion">
		<h3>文章</h3>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=article">全部</a>        
		</div>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=article&type=report">读书报告</a>        
		</div>
		<div class="mySidebarItem">        
	          <a href="Home.jsp?tag=article&type=other">其他</a>        
		</div>
		<div class="mySidebarItem">        
	          <a href="AddPageForArticle.jsp?tag=write">写文章</a>        
		</div>
   </div>
</wiki:UserCheck>

	
   <div class="accordion-close">
		<h3>组员</h3>
		
<%
  WikiContext c = WikiContext.findContext( pageContext );

 

 	AuthorizationManager authMgr = c.getEngine().getAuthorizationManager();
 	UserManager userMgr = c.getEngine().getUserManager();

 	Principal[]  users=userMgr.getUserDatabase().getWikiNames();
	for( int i = 0; i < users.length; i++ )
    {
        String fullName = users[i].getName();
       
%>
		<div class="mySidebarItem">        
	          <a href="CheckHomepageExist.jsp?fullName=<%=fullName %>"><%=fullName %></a>        
		</div>
<%
	}
 %>
   </div>

 <%--  <div class="wikiversion"><%=Release.APPNAME%> v<wiki:Variable var="jspwikiversion" /> <wiki:RSSImageLink title='<%=LocaleSupport.getLocalizedMessage(pageContext,"fav.aggregatewiki.title")%>' /></div> --%>

</div>