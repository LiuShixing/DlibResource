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

<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8" %>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%
  WikiContext c = WikiContext.findContext(pageContext);
%>
<c:set var="frontpage" value="<%= c.getEngine().getFrontPage() %>" />

<wiki:Plugin plugin="IfPlugin" args="page='TitleBox' contains='\\\\S' " >[{InsertPage page=TitleBox class='titlebox alert' }]</wiki:Plugin>

<%
    
    String t = request.getParameter("tag");
    
   	Map<String,String> m = new HashMap<String,String>();
   	m.put("all","全部");
	m.put("deeplearning","深度学习");
	m.put("kg","知识图谱");
	m.put("med","医疗");
	m.put("edu","教育");
	m.put("other","其他");
	m.put("upload","上传");
	m.put("article","文章");
	m.put("papers","科研成果");
	m.put("viewpaper","科研成果");
	
	String title=null;
	if(t==null || t.equals("all"))
	{
	    title="全部";
	}else{
	    title=m.get(t);
	}
	   
     
 %>
<div class="header">

  <div class="topline">

    <div class="cage pull-left">
    <a class="logo pull-left"
        href="<wiki:Link page='${frontpage}' format='url' />"
       title="资源列表 ">Dlib资源</a>

    </div>

    <wiki:Include page="UserBox.jsp" />
    <wiki:Include page="SearchBox.jsp" />

    <wiki:Include page="AAvisitCounter.jsp" />
 
    <div class="pagename" title="<wiki:PageName />">
    <%=title %>
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