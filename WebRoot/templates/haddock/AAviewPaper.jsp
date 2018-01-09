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

<%@page import="servlet.Paper"%>
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
String id=request.getParameter("id");
String sql="select * from papers where id=?";
DBManager db=new DBManager(sql);
db.pst.setString(1, id);
ResultSet rs=db.pst.executeQuery();
Paper paper = new Paper();
if(rs.next())
{
	paper.setId(rs.getString("id"));
	paper.setTitle(rs.getString("title"));
	paper.setAuthors(rs.getString("authors"));
	paper.setKeywords(rs.getString("keywords"));
	paper.setInfo(rs.getString("info"));
	paper.setAbstact(rs.getString("abstract"));
	paper.setCustom_info(rs.getString("custom_info"));
}

rs.close();
db.close();

StringBuilder asb = new StringBuilder();
 for(String s:paper.getAuthors().split("/"))
 	asb.append(s+", ");
 StringBuilder ksb = new StringBuilder();
 for(String s:paper.getKeywords().split("/"))
 	ksb.append(s+"; ");
asb =  asb.delete(asb.length()-2,asb.length()-1);
 ksb = ksb.delete(ksb.length()-2,ksb.length()-1);
%>
<div class="paper_block">
	<div class="paperinfo">
		<div>
			<p class="title"><%=paper.getTitle() %></p>
			<p><%=asb %></p>
			<p><%=ksb %></p>
		</div>
	</div>  
	
	<br/>
	<br/>
	<p><%=paper.getAbstact() %></p>
	<br/>
	<p><%=paper.getInfo() %></p>
	<br/>
	<label>备注：</label>
	<p><%=paper.getCustom_info() %></p>
</div>
<wiki:Content />

