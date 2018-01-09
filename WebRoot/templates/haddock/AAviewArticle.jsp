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
<%@page import="javax.sound.midi.MidiDevice.Info"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Map"%>
<%@page import="servlet.ResourceInfo"%>
<%@page import="servlet.MyUtil"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.attachment.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>


<%
String id=request.getParameter("page");
String sql="select title,author,time,label from articles left join article_labels on id=artid where id=?";
DBManager db=new DBManager(sql);
db.pst.setString(1, id);
ResultSet rs=db.pst.executeQuery();
String article_title=null;
String author=null;
Date time=null;
String label = null;
if(rs.next())
{
	article_title=rs.getString(1);
	author=rs.getString(2);
	time=rs.getDate(3);
	label = rs.getString(4);
}
String showlabels = "";
if(label != null)
{
	showlabels = label.replace("/", "; ");
}
rs.close();
db.close();
SimpleDateFormat ddf = new SimpleDateFormat("yyyy-MM-dd");
%>
<div class="info">
	<p class=" title bold-font changeLine"><%=article_title %></p>	
	<%-- <p class=" changeLine"><%=author %>&nbsp发表于&nbsp&nbsp<%=ddf.format(time) %>. --%>
	<p class=" changeLine"><a href="CheckHomepageExist.jsp?fullName=<%=author %>"><%=author %></a>&nbsp发表于&nbsp&nbsp<%=ddf.format(time) %>.    
	&nbsp&nbsp&nbsp&nbsp标签：<%=showlabels %>
	</p>
</div>  
<wiki:Content />

